# Welcome to Mortar!

Mortar is a platform-as-a-service for Hadoop.  With Mortar, you can run jobs on Hadoop using Apache Pig and Python without any special training.

# GitHub Top Projects

This Mortar project uses data available from http://www.githubarchive.org/ to determine the most popular Public repositories in GitHub for each month.  There are two scripts included:

## preprocess_events.pig

This is a script that was used to filter the raw event data down to a subset that is used for determining popularity.  

This script is a good example of a Pig script used for cleaning and structuring some raw data.

## top_projects.pig

This script takes our pre-processed GitHub data and does some simple logic to determine the most popular GitHub repos each month.

# Getting Started

1. [Signup for a Mortar account](https://app.mortardata.com/signup)
1. [Install the Mortar Development Framework](http://help.mortardata.com/#!/install_mortar_development_framework)
1. Clone this repository to your computer:

        git clone git@github.com:mortarcode/github_top_projects.git
        cd github_top_projects

Once you've setup the project, use the `mortar local:illustrate` command to show data flowing through a given script.  Use `mortar local:run` to run the script locally on your own computer.

### Registering your Mortar Project

To register your Mortar project you will need to upgrade your Mortar account.  You can view the available plans [here](https://app.mortardata.com/account#!/plans).

All Mortar projects share a global namespace so for this project you should prepend your handle to the project name in order to avoid namespace collisions.

        mortar register <your-handle>-github_top_projects

### Running in the cloud

Once your project is registered you can run it on a 10-node Hadoop cluster using `mortar run pigscripts/top_projects.pig -f params/cloud.params`

## Help

For lots more help and tutorials on running Mortar, check out the [Mortar Help](http://help.mortardata.com/) site.
