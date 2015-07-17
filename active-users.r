library("ggplot2")
library("grid")

CSV_PATH = "data/test-data.csv"
CSV_SEPARATOR = "\t"
BACKGROUND_COLOR = "#F6F8FA"
GRID_COLOR = "#DDDDDD"

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
	# We'll only analyze cohorts that contain new users
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
			# Is there a way to do this without the two loops?
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
	graph <- graph + ggtitle("Active Users by Month\nBroken Down by Sign Up Cohort")
	graph <- graph + theme(plot.title = element_text(lineheight = 1.2, face = "bold", size=rel(1.5)))
	graph <- graph + theme(axis.ticks = element_blank())
	graph <- graph + theme(plot.background = element_rect(fill = BACKGROUND_COLOR))
	graph <- graph + theme(panel.background = element_blank())
	graph <- graph + theme(panel.grid.major = element_line(color = GRID_COLOR, size = 0.2))

	# Call print so that the graph is rendered in RStudio
	print(graph)
}

Run()
