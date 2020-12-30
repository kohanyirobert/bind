# About

Terraform automation that creates two name servers under two separate GCP accounts within free tier limits.

## Prerequisites

- Have access to two separate GCP accounts
- Have control over a domain name (e.g. _example.com._)
- Create an SSH keypair (using `ssh-keygen`) for the Unix user account used to connect to the name server machines to be created (e.g. `id_rsa{.pub}`)
- Create a TSIG key (using `tsig-keygen`) to be used for secure zone transfers between name server (e.g. named `ns1-ns2`, saved to `ns1-ns2.key`)
- Create a TSIG key to be used for secure DDNS updates (e.g. named `ddns`, saved to `ddns.key`)

Note: `tsig-keygen` generates files using tabs instead of spaces in it, to overcome this use `tsig-keygen ddns | sed 's/\t/  /g' > ddns.key`.

## Steps for each account

- Create a new project
- Create an _Editor_ service account for Terraform
- Save the service account credentials (e.g. `ns{1,2}_credentials.json`)

Note: examine default firewall rules associated with default VPCs since those won't be touched by Terraform.

## Steps for the first account

- Create a storage bucket for Terraform to store its state in
- Run `terraform init -backend-config bucket=<bucket-name>`

## Provision name servers

- Create `terraform.tfvars` to provide values for variables defined in `variables.tf` (see `terraform.tfvars.example`)
- Run `terraform apply` to provision the name servers

## Delegate zone to name servers

- Delegate to your name servers (_ns1.example.com._ and _ns2.example.com._) at your registrar
- This is required to create _glue records_ in the _com._ parent domain
- Run `terraform output` to view the static external IP addresses assigned to the name servers

Note: to view if glue records are in place already use `dig +norecurse @$(dig +short com. NS | head -1) ns1.example.com. NS`

## Update DNS records

Use `nsupdate` with the `ddns.key`.

```sh
nsupdate -k ddns.key << EOF
debug
update add sample.example.com. 60 A 127.0.0.1
send
EOF
```

## Remote access

Use one of these

- `ssh -i id_rsa user@ns{1,2}.example.com`
- `mosh --ssh='ssh -i id_rsa' user@ns{1,2}.example.com`
- `wsl -- mosh --ssh='ssh -i id_rsa' user@ns{1,2}.example.com`

Note: some time must pass before `ns{1,2}.example.com` are properly resolved.

When SSH host keys change on the servers `.ssh/known_hosts` must be updated

- `ssh-keygen -R ns{1,2}.example.com`
- `wsl -- ssh-keygen -R ns{1,2}.example.com`

Note: create `/etc/wsl.conf` with the following contents when using `wsl` with SSH keys located under `/mnt`

```text
[automount]
options = "metadata"
```

then do `wsl --shutdown` and `wsl -- chmod 600 id_rsa`.
