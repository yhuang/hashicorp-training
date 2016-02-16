Terraform loads all configuration files within the directory specified in alphabetical order.

The files loaded must end in either .tf or .tf.json to specify the format that is in use; otherwise, the files are ignored. Multiple file formats can be present in the same directory.

https://www.terraform.io/docs/configuration/load.html

The output `terraform graph 02-instances-lb` can be visualized online at http://www.webgraphviz.com/.

When running `terraform plan`, Terraform performs a refresh, unless explicitly disabled, and then determines what actions are necessary to achieve the desired state specified in the configuration files.  The plan can be saved using `-out` and then provided to `terraform apply` to ensure only the pre-planned actions are executed.
