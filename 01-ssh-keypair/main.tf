// If we run `terraform plan 01-ssh-keypair` right now, Terraform prompt for
// credentials.  Let's generate new credentials and add them to the tfvars file.

// Next, run `terraform plan 01-ssh-keypair`.  You will notice Terraform uses
// the "+" to denote a new resource being added.  Terraform will similarly use a
// "-" to denote a resource that will be removed, and a "~" to indicate a
// resource that will have changes attributes.

// You may notice some additional resources in the plan output.  These resources
// live in the `aws.tf` file and include some important AWS-specific setup
// information such as VPCs and Security Groups.  You can safely ignore this for
// now as it is provider-specific.

// Run `terraform apply 01-ssh-keypair`.  This operation should be quick
// since we are only creating one resource.  You should see output very similar
// to the output of the `terraform plan 01-ssh-keypair`.

// If you open the Amazon console and look under EC2 -> Key Pairs, you will see
// a new key pair has been created named "terraform-tutorial".  We can use this
// key pair to connect to new EC2 instances created on Amazon in the next parts
// of this tutorial.

// Finally, run `terraform plan 01-ssh-keypair` again.  You will notice that the
// output indicates no resources are to change.  To further illustrate the power
// of Terraform, run `terraform apply 01-ssh-keypair` again.  Terraform will
// refresh the remote state (more on this later), and then 0 resources will be
// changed.  Terraform is intelligent enough to maintain and manage state.

// Before going any further, let's do some critical thinking.  What will happen
// if you delete this key pair from EC2 outside of Terraform (via the
// web interface, for example)?  Will Terraform recreate it?  Will Terraform
// throw an error?  Will Terraform ignore it? Let's try that out and see!

// Go into the Amazon Key Pair page in the AWS Console and delete the key using
// the Web UI.  Back on your local terminal, run `terraform plan 01-ssh-keypair`.
// Viola!  Terraform has intelligently detected that the key pair was removed
// out-of-band and recreated it for us.

// What will happen if we rename this resource in Terraform?  Suppose we want to
// add a better description to this key name, including the date of today's
// tutorial. Update the `key_name` in this Terraform configuration to be
// "terraform-tutorial-<date>" and run `terraform plan 01-ssh-keypair`.
// Terraform will detect the rename and alter the resource automatically!  We
// could apply these changes, but let's not do that. The remaining sections of
// this tutorial will assume the key pair is named "terraform-tutorial".  You
// can delete the date from the key pair name and verify nothing has changed by
// running the `terraform plan 01-ssh-keypair` command again.  If you
// accidentally ran `terraform apply 01-ssh-keypair`, do not worry - just
// change the name back and run `terraform apply 01-ssh-keypair` again.
