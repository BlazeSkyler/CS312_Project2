# CS312 Project Part 2

## Background

This GitHub repo contains files and scripts that automatically provision and configure the infrastructure needed to run a Minecraft server. The tools used are **Terraform** and **Docker**. Terraform is used to spin up an AWS EC2 instance. After that is created, an SSH connection is created to run bash scripts that install docker. A separate script is used to run the server using docker compose, which uses a .yml script that is put in the instance.

## Requirements

After cloning the repo, there a few steps needed before running the scripts.

1. Generate an SSH keypair if you don't already have one.

    - The following command can be used to generate a keypair:

    ```linux
    ssh-keygen -t rsa -b 4096 -a 100 -f ~/.ssh/id_rsa
    ```

    If the `.ssh` directory does not exist, you can create it using `mkdir ~/.ssh`.

    Ensure your private key has the correct permissions by running `chmod 400 ~/.ssh/id_rsa`.

    **Note**: The scripts assume that the private key path is `~/.ssh/id_rsa`. If your private key exists elsewhere, specify that path in line 82 of `terraform/main.tf`.

    ```HCL
    private_key = "${file("~/.ssh/id_rsa")}"
    ```

    - Set the "public_key" variable in `terraform/key.tfvars` with your public key. Using the command above, this is found in `~/.ssh/id_rsa.pub`.

2. [Install the Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

3. [Install the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

4. Configure AWS Credentials
    - Start your AWS (Academy Learner Lab)
    - In the top right, click **AWS Details**
    - In the right-hand menu where it says AWS CLI, click **Show**. Copy these credentials.
    - Create a file `~/.aws/credentials` and paste the credentials in the file.

    **Note**: The file can be created using `~/.aws/credentials`. If the `.aws` directory doesn't exist, create it using `mkdir ~/.aws`.

## Diagram

## How to Run

1. Navigate to terraform folder. If the repo was cloned in the home directory this can be done with `cd ~/CS312_Project2/terraform`.

2. Run `terraform init`.\
This initializes the directory by downloading and installing the providers defined in `main.tf`. In this case, AWS.

3. Run `terraform apply-var-file"key.tvars"`.\
This creates the infrastructure with every file that ends with .tf, including outputs.tf and variables.tf. The command also specifies a .tvars file, which is where your public key ***should*** be. This command creates the EC2 instance, puts the `docker-compose.yml` file in the instance, and runs `docker_install.sh` and `start_server.sh` through an SSH connection.

## How to Connect

After the `terraform apply-var-file"key.tvars"` command finishes executing, it will output the public IP of your EC2 instance. You can connect to the server from a Minecraft client by using <instance_public_ip>:25565.

**Note**: Even after the command finishes, the Minecraft server will take 2-5 minutes to start up. You can check if it is up using `nmap -sV -Pn -p T:25565 <instance_public_ip>`

## Sources

- [registry.terraform.io](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources)
- [developer.hashicorp.com - remote-exec](https://developer.hashicorp.com/terraform/language/resources/provisioners/remote-exec)
- [stackoverflow - terraform SSH connection](https://stackoverflow.com/questions/55745961/connection-issue-using-ssh-private-key)
- [github/itzg/docker-minecraft-server](https://github.com/itzg/docker-minecraft-server)
- [docs.docker.com - Ubuntu docker install](https://docs.docker.com/engine/install/ubuntu/)
