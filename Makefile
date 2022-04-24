# !!!! Should be executed only to initialixe Name Node FS. Otherwise all data will be erased !!!
format_namenode:
	hadoop namenode -format

ansible_namenode:
	ansible-playbook -i hosts --private-key ~/.ssh/akarmyzov-euc1.pem playbook.yml