/*
This script takes the raw event data from the github api and saves a subset of it used for
figuring out the most popular repos.

Required Parameters:
    * PROCESSED_EVENTS_OUTPUT_PATH - Path to the output data.
*/

--%default RAW_EVENT_LOGS_INPUT_PATH 's3n://mortar-example-data/github/raw_events/*/*/*/*'

%default DEFAULT_PARALLEL 27 
SET default_parallel $DEFAULT_PARALLEL

-- load the raw event logs
raw_events =  LOAD '$RAW_EVENT_LOGS_INPUT_PATH'
             USING org.apache.pig.piggybank.storage.JsonLoader('
                     actor: chararray, 
                     actor_attributes: ( 
                        gravatar_id: chararray, 
                        company: chararray
                     ), 
                     payload: (
                        ref_type: chararray
                     ),
                     repository: (
                        owner: chararray,
                        name: chararray,
                        fork: chararray,
                        language: chararray,
                        description: chararray,
                        watchers: int,
                        stargazers: int,
                        forks: int
                     ),
                     type: chararray,
                     created_at: chararray
                   ');

-- Keep only events that signal that a user is interested in a repo
-- and the initial create event for the repo.  Also remove any row
-- with missing information.
filter_events = FILTER raw_events BY (
                  (
                    actor            IS NOT NULL AND
                    repository.owner IS NOT NULL AND
                    repository.name  IS NOT NULL AND
                    repository.fork  IS NOT NULL AND
                    type             IS NOT NULL AND
                    created_at       IS NOT NULL
                  )
                AND
                  (
                    type == 'ForkEvent'        OR
                    type == 'WatchEvent'       OR
                    type == 'PullRequestEvent' OR
                    type == 'PushEvent'        OR
                    (
                      type             == 'CreateEvent'  AND
                      payload.ref_type == 'repository'
                    )
                  )
                AND
                  repository.name != 'try_git'
                );

-- Rename some fields to our common naming and create a unique name for each
-- repository by concatting the GitHub account with the repository name.
events_renamed  = FOREACH filter_events GENERATE
                    actor AS user,
                    CONCAT(repository.owner, CONCAT('/', repository.name)) AS item: chararray,
                    repository AS metadata,
                    type,
                    created_at AS timestamp;

-- Remove malformed repository names.
events = FILTER events_renamed BY SUBSTRING(item, 0, 1) != '/';

STORE events  INTO '$PROCESSED_EVENTS_OUTPUT_PATH' 
             USING org.apache.pig.piggybank.storage.JsonStorage();
