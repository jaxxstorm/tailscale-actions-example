# tailscale-actions-example

This repo is an example of using Tailscale with Terraform to connect to various environments.

It leverages Tailscale's [GitHub Action](https://github.com/tailscale/github-action) and [Subnet Routers](https://tailscale.com/kb/1019/subnets) to allow Terraform to manage resources in a private subnet, in this particular case, adding a MySQL database to an RDS instance.

![Architecture Diagram](https://i.imgur.com/Yuz6ciw.png)
