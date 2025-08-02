### Steps to Install Terraform on CentOS Stream 8:

Install yum-utils: This package provides yum-config-manager, which is needed to manage your repositories.

```
    sudo yum install -y yum-utils
```

Add the HashiCorp Repository: Add the official HashiCorp Linux repository to your system's repository list.


```
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
```

Install Terraform: Now that the repository is added, you can install Terraform using yum.

```
    sudo yum install -y terraform
```

Verify the Installation: After the installation completes, verify that Terraform is installed correctly and is accessible in your system's PATH.

```
    terraform --version
```