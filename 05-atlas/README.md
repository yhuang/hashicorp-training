Setting up a Git Repository
===========================
1. Create a repository on GitHub under your user named "training"

1. Change directory (`cd`) into the `04-atlas` directory

1. Run

        $ git init

1. Run

        $ git commit -a -m "Initial commit"

1. Run

        $ git remote add origin git@github.com:<username>/training.git

1. Run

        $ git push -u origin master


Setting up Packer in Atlas
==========================
1. Navigate to Atlas
1. Click on "Builds" in the navigation bar
1. Click on "New Build Configuration"
1. Create a configuration named "web" and check the "Automatically build on version uploads" option
1. Go to the "Variables" page and add the following
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
1. Go to the "Integrations" page and select your GitHub repo:
  - GitHub repo: `<username>/training`
  - GitHub directory: `packer`
  - Packer template: `web.json`

- - -

1. Click on "Builds" in the navigation bar
1. Click on "New Build Configuration"
1. Create a configuration named "haproxy" and check the "Automatically build on version uploads" option
1. Go to the "Variables" page and add the following
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
1. Go to the "Integrations" page and select your GitHub repo:
  - GitHub repo: `<username>/training`
  - GitHub directory: `packer`
  - Packer template: `haproxy.json`

- - -

1. Change directory (`cd`) into the `04-atlas` directory
1. Run

        $ git commit -m "Trigger initial builds" --allow-empty
        $ git push origin master

1. Look in Atlas UI and see builds running
