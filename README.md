# Active User Cohort Analysis in R

This is an R script that allows you to analyze active users by sign up cohort.

## How it works

If you run a web or mobile app, you might be interested to know how many active users your app has each month. This R script will not only help you figure that out, but it will break down the active users each month into cohorts based on when the user was first seen.

In order for it to work, all you need to do is to generate a CSV file containing a list of user ids and dates when the users performed actions in your app. See `data/test-data.csv` for the format.

You'll need to edit the `DATA_PATH` and `DATA_FILE_SEPARATOR` at the top of `active-users.r` depending on where you place the data file and whether the file comma-separated or tab-separated.

## Testing the script

Within RStudio, simply load the script using `source("active-users.r");`. If all went well, it should generate the following chart:

![Monthly cohort chart](images/monthly.png)

## Contact

If you have any suggestions, find a bug, or just want to say hey drop me a note at [@mhmazur](https://twitter.com/mhmazur) on Twitter or by email at matthew.h.mazur@gmail.com.

## License

MIT © [Matt Mazur](http://mattmazur.com)
