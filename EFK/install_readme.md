8. Install Fluentbit with Custom Values/Configurations
   👉 Note: Please update the HTTP_Passwd field in the fluentbit-values.yaml file with the password retrieved earlier in step 6: (i.e NJyO47UqeYBsoaEU)"

🧼 Clean Up

helm uninstall fluent-bit -n logging

helm uninstall kibana -n logging
helm uninstall elasticsearch -n logging

kubectl delete ns logging