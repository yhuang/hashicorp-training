Using GitHub + Atlas + Terraform
================================
You no longer need to run or manage Terraform locally. All you data is stored
and versioned securely in Atlas, backed by Vault.


Making Changes via SCM
----------------------
1. Click on the "README.md" file in GitHub
1. Click "edit"
1. Make any change
1. Check "Create a **new branch** for this commit"
1. Click "Propose file change"
1. Click "Create pull request"
1. Notice the yellow status icon - click on it
1. See the plan running in Atlas
1. See that the plan has no changes
1. Back in the GitHub UI, see the green checkbox
1. Merge the Pull Request
1. Go to the environment in Atlas
1. See that the merge is queuing a plan - it will have "no changes"


Making Infrastructure Changes via SCM
-------------------------------------
1. Edit the file "terraform/main.tf" and bump the `count` attribute to 2
1. Check "Create a **new branch** for this commit"
1. Click "Propose file change"
1. Click "Create pull request"
1. Notice the yellow status icon - click on it
1. Watch the plan and look at the output
1. Notice that resources are changed, but you cannot apply it (because it is
  from a Pull Request)
1. Merge the Pull Request
1. Go to the environment in Atlas
1. See that the merge is queuing a plan - it will have changes
1. Click on the plan
1. Assuming the output looks good, click "Confirm & Apply"
1. Watch as Atlas provisions two new instances for you
1. The new nodes will automatically join the Consul cluster and HAProxy, so you
  can hit your HAProxy once the nodes are healthy and see them
  as part of the response pool.


Making Scary Changes via SCM
----------------------------
1. Edit the file "terraform/aws.tf" and change the name of the
  `aws_security_group` on line 121
1. Check "Create a **new branch** for this commit"
1. Click "Propose file change"
1. Click "Create pull request"
1. Notice the yellow status icon - click on it
1. Watch the plan and look at the output
1. Notice that a bunch of things are changing
1. Do **not** merge the Pull Request because that's scary - there are
  potentially breaking changes, and Atlas alerted you to those changes via the
  output


Tearing it all down
-------------------
1. In Atlas, click on "environments" in the header
1. Click on your environment
1. Click on settings
1. Click "Queue destroy plan" on the bottom of the page - this is just like
  any other Terraform plan in Atlas, except this will destroy the resources. You
  will still need to confirm the plan in order to apply the changes.
1. Once that apply is finished, you can check in the AWS console and see that
  all the resources have been destroyed.
1. Back on the settings page, you can optionally delete all of Atlas' metadata
  about the environment by clicking the red "Delete from Atlas" button.
