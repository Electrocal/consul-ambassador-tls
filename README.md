# consul-ambassador-tls

A few configuration files for setting up DataWire's Ambassador to work securely with HashiCorp Consul

---

## Credits

- https://blog.getambassador.io/ambassador-edge-stack-to-consul-connect-759426ad95d9
- https://discuss.hashicorp.com/t/consul-verified-tls-from-pods-in-kubernetes-cluster/9208/11

---
# A few things about this repo 

I had quite a struggle getting Ambassador to talk over TLS to Consul while trusting Consul's generated CA and hopefully this can help you out if you're facing the same issue. I do hope in the near future to write a small starter blog post on this :)

Q: **Why isn't this just a Helm chart???**

A: I eventually plan to modify this into a singular Helm chart `values.yaml` file so people don't have to install these one by one. 

Q: **Namespaces?**

A: As secrets don't travel well, follow the getting started guide below, making sure to *install both Consul & Ambassador to the same namespace*.
 
---

# Getting Started

### Set up

Clone this repo locally. A few small modifications are needed to set your namespaces & DC name. 
I've tried to make this a little bit simpler by creating a `setup.sh` script which will prompt & set the values.

```sh
chmod +x setup.sh && ./setup.sh
```

consul-values.yaml is set with a few values from this guide, you can modify it to what you need by following this tutorial: 
 https://learn.hashicorp.com/tutorials/consul/kubernetes-secure-agents?in=consul/kubernetes 

---

### Consul

Get the Hashicorp repository:
```sh
$ helm repo add hashicorp https://helm.releases.hashicorp.com
```
**Important if using ACLs (just skip if not): Create the shared gossip encryption key**
To run this command, you will need the Consul binary installed to your local machine

```sh
$ kubectl create secret generic consul-gossip-encryption-key --from-literal=key=$(consul keygen) -n {namespace}
```

Install Consul using the following command:
```sh
$ helm install consul -f consul-values.yaml hashicorp/consul -n {namespace}
```

--- 

### Ambassador

The ambassador install is relatively straightforward but is broken into a few files while I work on forking & building a workable helm chart:

```sh
$ kubectl apply -f ambassador-rbac-tls.yaml -n {namespace}
```

Install the required CRDs

```
$ kubectl apply -f https://www.getambassador.io/yaml/aes-crds.yaml
```

```sh
$ kubectl apply -f consul-resolver.yaml -n {namespace}
```

```sh
$ kubectl apply -f ambassador-consul-connector-tls.yaml -n {namespace}
```

Load your public certificate in as a kubernetes secret:

```sh
kubectl create secret tls ambassador-certs --cert=certificate.pem --key=key.pem -n {namespace}
```
Deploy the ambassador service:
```sh
$ kubectl apply -f ambassador-service-tls.yaml -n {namespace}
```

You should now have the required dependencies all set up for Ambassador to connect over TLS to Consul! 

From here, continue working from the official docs as they explain it much better than I can & give example services: 
https://blog.getambassador.io/ambassador-edge-stack-to-consul-connect-759426ad95d9
