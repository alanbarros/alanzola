#!/bin/bash
set -e
set -o pipefail

echo ${TOKEN}

if [[ -n "$TOKEN" ]]; then
    GITHUB_TOKEN=$TOKEN
fi

if [[ -z "$PAGES_BRANCH" ]]; then
    PAGES_BRANCH="gh-pages"
fi

if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "Set the GITHUB_TOKEN env variable."
    exit 1
fi

if [[ -z "$REPO_GITHUB_IO" ]]; then
    echo "Set the REPO_GITHUB_IO env variable."
    exit 1
fi

if [[ -z "$ZOLA_BASE_URL" ]]; then
    CHANGE_BASE_URL=true
    exit 1
fi

main() {
    echo "Starting deploy..."

    echo "Fetching themes"
    git config --global url."https://".insteadOf git://
    git config --global url."https://github.com/".insteadOf git@github.com:
    git submodule update --init --recursive

    zola=./zola
    
    chmod +x $zola

    version=$($zola --version)
    remote_repo="https://${GITHUB_TOKEN}@github.com/${REPO_GITHUB_IO}.git"
    remote_branch=$PAGES_BRANCH

    echo "Using $version"

    $zola build --base-url=$ZOLA_BASE_URL

    echo "Pushing artifacts to ${REPO_GITHUB_IO}:$remote_branch"

    cd public
    git init
    git config user.name "GitHub Actions"
    git config user.email "github-actions-bot@users.noreply.github.com"
    git add .

    git commit -m "Deploy ${REPO_GITHUB_IO} to ${REPO_GITHUB_IO}:$remote_branch"
    git push --force "${remote_repo}" master:${remote_branch}

    echo "Deploy complete"
}

main "$@"