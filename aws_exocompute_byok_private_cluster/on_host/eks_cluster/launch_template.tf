locals {
  # For the us-east-1 region the hostname suffix is compute.internal. For all
  # other regions, the hostname suffix is in the form <region>.compute.internal.
  hostname = var.aws_eks_cluster_region == "us-east-1" ? "compute.internal" : "${var.aws_eks_cluster_region}.compute.internal"
}

# https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html.
data "aws_ssm_parameter" "worker_image" {
  name = "/aws/service/eks/optimized-ami/${var.aws_eks_version}/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "worker" {
  name                   = "${var.aws_name_prefix}-rubrik-exocompute-worker-${var.aws_eks_cluster_region}"
  image_id               = data.aws_ssm_parameter.worker_image.value
  instance_type          = var.aws_eks_worker_node_instance_type
  vpc_security_group_ids = [aws_security_group.node.id]

  block_device_mappings {
    device_name = "/dev/sdb"
    ebs {
      volume_size = 60
      volume_type = "gp3"
    }
  }

  iam_instance_profile {
    name = var.aws_eks_worker_node_instance_profile
  }

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      "Name"                                                     = "${var.aws_name_prefix}-node"
      "kubernetes.io/cluster/${aws_eks_cluster.exocompute.name}" = "owned"
    }
  }

  # User data attached with the launch configuration to run when starting the
  # worker nodes.
  #
  # We perform the following actions:
  #   1. Update the hostname of the node. Kubernetes uses the hostname as a
  #      label and hence requires it to be restricted to 63 chars. If the
  #      hostname is greater than 63 chars, we update the hostname to the
  #      default hostname.
  #   2. Create 255 loop devices. Loop devices are used by CDM indexing code.
  #      This ensures that each pod has access to enough loop devices. Earlier
  #      we tried created loop devices inside the pod rather than at node
  #      startup, but that lead to errors in finding loop devices which is
  #      hypothesized to be due to multiple pods trying to create loop devices
  #      concurrently.
  #   3. Run EKS bootstrap script which starts kubelet and register the worker
  #      with the EKS cluster.
  user_data = base64encode(<<-EOF
              #!/bin/bash
              set -o xtrace

              host=$(hostname)
              if [[ $${#host} -gt 63 ]]; then
                  hostnamectl set-hostname $(hostname | cut -d "." -f 1).${local.hostname}
              fi

              # Create loop devices, this is taken from CDM code:
              # src/scripts/vmdkmount/make_loop.sh
              NUM_LOOP_DEVICES=255
              LOOP_REF="/dev/loop0"
              if [ ! -e $LOOP_REF ]; then
                  /sbin/losetup -f
              fi

              for ((i = 1; i < $NUM_LOOP_DEVICES; i++)); do
                if [ -e /dev/loop$i ]; then
                  continue;
                fi
                mknod /dev/loop$i b 7 $i;
                chown --reference=$LOOP_REF /dev/loop$i;
                chmod --reference=$LOOP_REF /dev/loop$i;
              done

              # Remove LVM on host, just to avoid any interference with containers.
              yum remove -y lvm2

              #Source the env variables before running the bootstrap.sh script
              set -a
              source /etc/environment

              # https://github.com/awslabs/amazon-eks-ami/blob/master/files/bootstrap.sh
              /etc/eks/bootstrap.sh ${aws_eks_cluster.exocompute.name} --b64-cluster-ca ${aws_eks_cluster.exocompute.certificate_authority[0].data} --apiserver-endpoint ${aws_eks_cluster.exocompute.endpoint}
              EOF
  )
}
