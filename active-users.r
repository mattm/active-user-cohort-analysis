CSV_PATH = "data/test-data.csv"
CSV_SEPARATOR = "\t"

Run <- function() {
	activities <- LoadActivityData()
	data <- AnalyzeActiveUserCohorts(activities)
	PlotActiveUserCohorts(data)
}

LoadActivityData <- function() {
	activities <- read.csv(CSV_PATH, sep = CSV_SEPARATOR,
		col.names = c("user.id", "date"), header = FALSE)
	activities$date <- as.Date(activities$date)
	activities$cohort <- format(activities$date, "%Y-%m")
	activities
}

AnalyzeActiveUserCohorts <- function(activities) {
	users <- GetUserSignupCohorts(activities)

	# Figure out all of the cohorts that we need to analyze
	# TODO: What happens if there is month without any data?
	cohorts <- sort(unique(users$cohort))

	# Construct a data frame that we can supply to ggplot
	signup.cohorts <- vector()
	activity.cohorts <- vector()
	active.users <- vector()
	for (signup.cohort in cohorts) {

		# Figure out which users signed up in this cohort
		signup.user.ids <- users[users$cohort == signup.cohort, "user.id"]
		for (activity.cohort in cohorts) {

			# Figure out which activities those users performed in every other cohort
			# including cohorts before they signed up (required for ggplot stacking)
			user.activities <- activities[activities$user.id %in% signup.user.ids
				& activities$cohort == activity.cohort, ]

			# If a user performed multiple activities in a cohort, only count it once
			unique.users <- unique(user.activities$user.id)

			# Keep track of each vector so we can construct the data frame afterwards
			# TODO: There is probably a more elegant way to do this
			signup.cohorts <- append(signup.cohorts, signup.cohort)
			activity.cohorts <- append(activity.cohorts, activity.cohort)
			active.users <- append(active.users, length(unique.users))
		}
	}

	data.frame(signup.cohorts, activity.cohorts, active.users)
}

# We determine which cohort each user belongs to based on his first activity
GetUserSignupCohorts <- function(activities) {
	aggregate(cohort ~ user.id, activities, min)
}

PlotActiveUserCohorts <- function(data) {

	# Convert the sign up month cohorts ("2015-01", etc) to
	# dates so they can be used in in the ggplot below
	data$activity.cohorts <- as.Date(paste(data$activity.cohorts, "-01", sep = ""))
	graph <- ggplot(data,
		aes(x = activity.cohorts, y = active.users, fill = as.factor(signup.cohorts)))
	graph <- graph + geom_area()
	graph <- graph + labs(x = "Sign Up Month", y = "Active Users")
	graph <- graph + guides(fill = FALSE)

	# Call print so that the graph is rendered in RStudio
	print(graph)
}

Run()
