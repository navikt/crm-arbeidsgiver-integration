const { Octokit } = require("@octokit/action");

merge()

async function merge() {
	const octokit = new Octokit();
	const [owner, repo] = process.env.GITHUB_REPOSITORY.split("/");

	const pullRequests = await octokit.paginate(
		"GET /repos/:owner/:repo/pulls",
		{
			owner,
			repo,
			state: "open"
		},
		({ data }) => {
			return data.filter(hasScheduleCommand).map(pullRequest => {
				return {
					number: pullRequest.number,
					html_url: pullRequest.html_url,
					scheduledDate: getScheduleDateString(pullRequest.body)
				};
			});
		}
	);

	console.log(`${pullRequests.length} scheduled pull requests found`);

	if (pullRequests.length === 0) {
		return;
	}

	const duePullRequests = pullRequests.filter(
		pullRequest => new Date(pullRequest.scheduledDate) < new Date()
	);

	console.log(`${duePullRequests.length} due pull requests found`);

	if (duePullRequests.length === 0) {
		return;
	}

	for await (const pullRequest of duePullRequests) {
		await octokit.pulls.merge({
			owner,
			repo,
			pull_number: pullRequest.number
		});
		console.log(`${pullRequest.html_url} merged`);
	}
}