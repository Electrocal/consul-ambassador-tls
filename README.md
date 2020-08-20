# consul-ambassador-tls

A few configuration files for setting up DataWire's Ambassador to work securely with HashiCorp Consul

---

## Credits

https://blog.getambassador.io/ambassador-edge-stack-to-consul-connect-759426ad95d9
https://discuss.hashicorp.com/t/consul-verified-tls-from-pods-in-kubernetes-cluster/9208/11

---
# A few things about this repo 

I had quite a struggle getting Ambassador to talk over TLS to Consul while trusting Consul's generated CA and hopefully this can help you out if you're facing the same issue. I do hope in the near future to write a small 'getting started' blog post on this :)

Q: Why isn't this just a Helm chart???
A: I hope soon to modify this into a singular Helm chart values.yaml file so people don't have to install these one by one. 

Q: Anything I should worry with namespaces?
A: Install both Consul from HashiCorp's official helm chart & this to the same namespace as the TLS cert from Consul is set as a secret.

Q: Am I missing any files I need to get started? 
A: I've only provided the files needed to get this to work with TLS, for everything else such as the ambassador service, I'd follow these tutorials:
 - https://www.consul.io/docs/k8s/ambassador
 - https://www.getambassador.io/docs/latest/howtos/consul/
 
