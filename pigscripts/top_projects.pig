/*
Find the most popular project by month by looking at the repos
with the highest number of Fork and Watch events.

Parameters:
    * EVENT_LOGS_INPUT_PATH - Path to input events json files
    * OUTPUT_PATH - Path to output
    * DEFAULT_PARALLEL - default # of reducers to use
    * MIN_SCORE - Minimum score to include in results

Defaults are for local development
*/

%default EVENT_LOGS_INPUT_PATH '../data/events.json'
%default OUTPUT_PATH '../output/out'
%default DEFAULT_PARALLEL 1
%default MIN_SCORE 1

SET default_parallel $DEFAULT_PARALLEL

-- Load github event data
events =  LOAD '$EVENT_LOGS_INPUT_PATH' 
         USING org.apache.pig.piggybank.storage.JsonLoader('
                 item: chararray, 
                 type: chararray, 
                 timestamp: chararray'
               );


-- Only count events that are a sign of popularity.
scorable_events = FILTER events BY type == 'ForkEvent' or type == 'WatchEvent';


-- Get year-month string for each event
events_with_date = FOREACH scorable_events GENERATE 
                     item, 
                     SUBSTRING(timestamp, 0, 7) as year_month:chararray
                   ;


-- Sum up the number of events each repo in each month.
repo_scores = FOREACH (GROUP events_with_date BY (year_month, item)) GENERATE
                flatten(group),
                COUNT(events_with_date) as score
              ;


-- Find the top 5 repos for each month that are over some threshold score.
top_repos = FOREACH (GROUP repo_scores BY year_month) {
              filtered = FILTER repo_scores BY score > $MIN_SCORE; 
              ordered = ORDER filtered BY score DESC;
              limited = LIMIT ordered 5;
              GENERATE flatten(limited);
            }


-- Format output: ensure sort order and use only one reducer to get one output file.
results = ORDER top_repos BY year_month, score DESC PARALLEL 1;


rmf $OUTPUT_PATH;
STORE results INTO '$OUTPUT_PATH';
