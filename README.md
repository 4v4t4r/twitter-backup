##Twitter Backup Script

This is a script to backup a users timeline to a JSON file.

This script was modified from a version that wrote to a MongoDB instance; where I wanted the data saved to a flat-file to keep it portable and minimize the requirements to run this from CRON on a server.

## Usage

`ruby backup.rb <username>`

This will produce a file called <username>.json - it will start from the last tweet in the file, so it allows you to maintain a complete history even if you pass the 3200 tweets that the API can return.

## Notes

I freely admit I'm far from an expect with Ruby - for that matter, I'm far from knowledgable, so please don't look at my changes to this project and assume it's the right way to do any of it. Because it's not. It can't be.
