#!/usr/bin/env groovy

REPOSITORY = "publishing-e2e-tests"
DEFAULT_PUBLISHING_API_COMMITISH = "master"

node("docker") {

  def govuk = load("/var/lib/jenkins/groovy_scripts/govuk_jenkinslib.groovy")

  properties([
    parameters([
      stringParam(
        defaultValue: "",
        description: "Which repo (if any) triggered this build. eg publishing-api",
        name: "ORIGIN_REPO"
      ),
      stringParam(
        defaultValue: "",
        description: "The full SHA1 hash of the commit from ORIGIN_REPO which triggered this build",
        name: "ORIGIN_COMMIT"
      ),
      stringParam(
        defaultValue: DEFAULT_PUBLISHING_API_COMMITISH,
        description: "Which commit/branch/tag of publishing-api to clone",
        name: "PUBLISHING_API_COMMITISH"
      )
    ])
  ])

  govuk.initializeParameters([
    "ORIGIN_REPO": "",
    "ORIGIN_COMMIT": "",
    "PUBLISHING_API_COMMITISH": DEFAULT_PUBLISHING_API_COMMITISH,
  ])

  def originBuildStatus = { message, status ->
    if (params.ORIGIN_REPO && params.ORIGIN_COMMIT) {
      step([
          $class: "GitHubCommitStatusSetter",
          commitShaSource: [$class: "ManuallyEnteredShaSource", sha: params.ORIGIN_COMMIT],
          reposSource: [$class: "ManuallyEnteredRepositorySource", url: "https://github.com/alphagov/${params.ORIGIN_REPO}"],
          contextSource: [$class: "ManuallyEnteredCommitContextSource", context: "continuous-integration/jenkins/publishing-e2e-tests"],
          errorHandlers: [[$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]],
          statusResultSource: [ $class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", message: message, state: status]] ]
      ]);
    }
  }

  lock("publishing-e2e-tests-$NODE_NAME") {
    try {
      originBuildStatus("Running publishing end-to-end tests on Jenkins", "PENDING")

      stage("Checkout") {
        checkout(scm)
      }

      stage("Build") {
        withEnv(["PUBLISHING_API_COMMITISH=${params.PUBLISHING_API_COMMITISH}"]) {
          sh("make clone -j4")
          sh("make build")
          sh("make start")
          sh("make test")
          sh("make stop")
        }
      }

      originBuildStatus("Publishing end-to-end tests succeeded on Jenkins", "SUCCESS")

    } catch (e) {
      currentBuild.result = "FAILED"
      step([$class: "Mailer",
            notifyEveryUnstableBuild: true,
            recipients: "govuk-ci-notifications@digital.cabinet-office.gov.uk",
            sendToIndividuals: true])

      originBuildStatus("Publishing end-to-end tests failed on Jenkins", "FAILED")

      throw e
    } finally {
      sh("make stop")
    }
  }
}
