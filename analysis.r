PlotActiveUserCohorts <- function(data) {
	#cohortData <- read.csv("2010-cohorts.csv")

	# Convert the sign up month cohorts ("2015-01", etc) to
	# dates so they can be used in in the ggplot below
	data$signed.up <- as.Date(paste(data$signed.up, "-01", sep = ""))
	graph <- ggplot(data,
		aes(x = signed.up, y = active.users, fill = active))
	graph <- graph + geom_area()
	graph <- graph + labs(x = "Sign Up Month", y = "Active Users")
	graph <- graph + guides(fill = FALSE)

	# Call print so that the graph is rendered in RStudio
	print(graph)
}

activities <- read.csv("test-data.csv", sep = "\t",
	col.names = c("user.id", "date"), header = FALSE)
activities$date <- as.Date(activities$date)
activities$cohort <- format(activities$date, "%Y-%m")

# We determine which cohort each user belongs to based on his first activity
users <- aggregate(cohort ~ user.id, activities, min)

# Figure out all of the cohorts that we need to analyze
# TODO: What happens if there is month without any data?
cohorts <- sort(unique(users$cohort))

# Construct a data frame that we can supply to ggplot
signed.up <- vector()
active <- vector()
active.users <- vector()
for (signed.up.cohort in cohorts) {

	# Figure out which users signed up in this cohort
	signed.up.user.ids <- users[users$cohort == signed.up.cohort, "user.id"]
	for (activity.cohort in cohorts) {

		# Figure out which activities those users performed in every other cohort
		# including cohorts before they signed up (required for ggplot stacking)
		user.activities <- activities[activities$user.id %in% signed.up.user.ids
			& activities$cohort == activity.cohort, ]

		# If a user performed multiple activities in a cohort, only count it once
		unique.users <- unique(user.activities$user.id)

		# Keep track of each vector so we can construct the data frame afterwards
		# TODO: There is probably a more elegant way to do this
		signed.up <- append(signed.up, signed.up.cohort)
		active <- append(active, activity.cohort)
		active.users <- append(active.users, length(unique.users))
	}
}

data <- data.frame(signed.up, as.factor(active), active.users)

PlotActiveUserCohorts(data)
