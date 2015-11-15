##Task 1: Installing Docker Universal Control Plane
In this task we're going to install the Docker Universal Control Plane (UCP) server onto **ducp-0**. This is done by running a bootstrap container, and providing a few pieces of information. 

**Note***: Normally the installer would pull the installation images from Docker Hub or Docker Trusted Registry (DTR), for this lab, we've prestaged the images onto your machine so you won't need to login to either Docker Hub or DTR*

**Note***: Some dialogs / logs will say "Orca" this is the internal code name for UCP*

1. SSH into **ducp-0**

		$ ssh ubuntu@<ducp-0 public ip>
	
 	**Note***: You may be prompted to accept the RSA key. If so, enter* `yes`
 	
 	**Note***: The default password is* `D0ckerconEU!`

2. Run the UCP installer

		docker run --rm -it \
		-v /var/run/docker.sock:/var/run/docker.sock \ 
		--name orca-bootstrap \
		dockerorca/orca-bootstrap \
		install -i
		
3. Provide the following inputs:

	- Password: `D0ckerconEU!`
	- Additional Aliases: `<ducp-0 Public DNS>` `<ducp-0 IP>`
	 
	  **Note***: Do not use the private IP. Use the one labled "IP"*

	The UCP installer should finish something similar to:
	
		INFO[0160] Installing Orca with host address 172.31.42.38
		INFO[0002] Generating Swarm Root CA
		INFO[0013] Generating Orca Root CA
		INFO[0022] Deploying Orca Containers
		INFO[0027] Orca instance ID: JJOB:SQP3:PERQ:UPP3:54UP:K7B6:ZWL6:GLES:CN7M:5KLO
		INFO[0027] Orca Server SSL: SHA1 Fingerprint=48:22:4F:6B:36:6D:
		INFO[0027] Login as "admin"/(your admin password) to Orca at https://<ducp-0 private IP>:443

1. In your web browser navigate to the UCP server via ducp-0's IP

	For example: `https://52.224.13.6`
	
	**Note***: You will be warned that your connection is not private. That is 	because we are not using publicly signed certificates for the SSL 	connnection to the website.*
	
	*To by pass this click `advanced` and then `proceed to . . . .` link*
	
2. Login into the UCP server with the username `admin` (case sensitive) and the 	password `D0ckerconEU!`
	
	You'll be logged into the UCP dashboard. Notice you have 7 containers, 7 	images, 1 node, and 0 applications running. These images and containers are 	what power the UCP server.
	
##Task 2: Deploy a Second Docker Host (NOT FINISHED)
One of UCP's capabilities is that it acts as a web-based front-end to Swarm. In this step we'll add a 2nd node (**ducp-1**) to for UCP to manage (which is the same as adding a second node to a Swarm cluster). 

1. In a new terminal session SSH into **ducp-1**

		$ ssh ubuntu@<ducp-1 public ip>
	
 	**Note***: You may be promted to accept the RSA key. If so, enter* `yes`
 	
 	**Note***: The default password is* `D0ckerconEU!`

2. Run the UCP bootstrap with the join option

		docker run --rm -it \
		-v /var/run/docker.sock:/var/run/docker.sock \ 
		--name orca-bootstrap \
		dockerorca/orca-bootstrap \
		join -i

3. Provide the following inputs:

	- URL to the Orca server: `https://<ducp-0 IP>`
	- Proceed with the join: `y`
	- Admin username: `admin`
	- Admin password: `D0ckerconEU!`
	- Additional Aliases: `<ducp-1 Public DNS>` `<ducp-1 IP>`

	The Installer should finish with something similar to:
	
		INFO[0000] This engine will join Orca and advertise itself with host address 10.0.11.13
		INFO[0000] Verifying your system is compatible with Orca
		INFO[0012] Starting local swarm containers
	
4. Go back to your web browser, and refresh the dashboard. You should now see you have 2 nodes running. 

5. Click `Nodes`

	Here you can see details on both of your running nodes


##Task 3: Create a Container
In this section we'll deploy an Nginx container using UCP

3. In the UCP UI click the menu button in the upper left corner

	![Menu](images/menu.png)

4. From the drop down select `Containers`

5. On the Orca / Networks page, click `+ Deploy Container`
	
6. Provide the following inputs:

	- Image Name: `nginx:latest`	
	- Container Name: `mynginx`
	- Under Network set port 80 to redirect to 8005 and click the `+` button

	![Ports](images/ports.png)
	
	Feel free to examine the other settings, but leave them at their defaults
	
5. Click `Run Container`

	![Run Container](images/run_container.png)
	
6. Click the magnifying glass next to  your container, and scroll down to find 	out which node your webserver is running on (`ducp-0` or `ducp-1`)

	In your web browser navigate to the IP address (and port 8005) of the node 	where Nginx is running. 

	For example: `http://52.23.41.23:8005`

	You should see the Nginx welcome screen.
	
## Task 4: Using UCP from the Command Line
One of the great things about UCP is that it doesn't preclude you from using the Docker command line tools you're used to. In this task we're going to install the UCP client bundle into an Ubuntu host in AWS.

1. SSH into **ducp-2**

		$ ssh ubuntu@<ducp-2 public IP>
		
   **Note***: You may be promted to accept the RSA key. If so, enter* `yes`
 	
 	**Note***: The default password is* `D0ckerconEU!`

2. Install jq

		$ sudo apt-get install jq
		
3. Install zip

		$ sudo apt-get install zip

1. Export the security token from the UCP server

		AUTHTOKEN=$(curl -sk -d '{"username":"admin","password":"D0ckerconEU!"}' https://<ducp-0 IP>/auth/login | jq -r .auth_token)
		
	
2. Curl the client bundle down to your 

		curl -k -H "X-Access-Token:admin:$AUTHTOKEN" https://<ducp-0 IP>/api/clientbundle -o bundle.zip
		
3. Unzip the client bundle
		
		$ unzip bundle.zip
		
7. Execute the `env.sh` script to set the appropriate environment variables for 	your UCP deployment

		$ source env.sh
		
9. Run `docker info` to examine the configuration of your Docker Swarm

		$ docker info
		Containers: 10
		Images: 15
		Role: primary
		Strategy: spread
		Filters: health, port, dependency, affinity, constraint
		Nodes: 2
		 orca-node-0: 10.0.10.47:12376
		  └ Containers: 7
		  └ Reserved CPUs: 0 / 1
		  └ Reserved Memory: 0 B / 3.859 GiB
		  └ Labels: executiondriver=native-0.2, kernelversion=3.19.0-26-generic, operatingsystem=Ubuntu 14.04.3 LTS, storagedriver=aufs
		 orca-node-1: 10.0.11.13:12376
		  └ Containers: 3
		  └ Reserved CPUs: 0 / 1
		  └ Reserved Memory: 0 B / 3.859 GiB
		  └ Labels: executiondriver=native-0.2, kernelversion=3.19.0-26-generic, operatingsystem=Ubuntu 14.04.3 LTS, storagedriver=aufs
		CPUs: 2
		Total Memory: 7.718 GiB
		Name: orca-node-0
		ID: F4Q3:NJRJ:GZ3M:6TKK:KUEE:TRUO:AEFG:ET7U:RAP4:3RHW:HYOH:I2TK
		Labels:
 		swarm_master=tcp://10.0.10.47:2376
			 
##Task 5: Use Docker Compose 
In this task we'll use Docker Compose to stand up a multi-tier voting application. 

1. Make sure you're SSH'd into **ducp-2**
		
3. Use the editor of your choice to createa  docker_compose.yml file, and copy the following commands into your new file. 

		voting-app:
  		image: dockercond2/dockercon-voting-app
		  links:
		    - redis:voteapps_redis_1
		  ports:
		    - "5000:80"

		redis:	
		  image: redis
		  ports: ["6379"]

		worker:	
		  image: dockercond2/dockercon-worker
	  links:
		    - redis:voteapps_redis_1
		    - db:voteapps_db_1

		db:
  		image: postgres:9.4

		result-app:
		  image: dockercond2/dockercon-result-app
		  links:
		      - db:voteapps_db_1
		  ports:
		    - "5001:80"
		
4. Standup the application. The compose file will stand up 4 different 	containers that comprise an app that stands up voting application

		$ docker-compose up -d
		
	It will take a couple minutes for the compose to complete, and several lines 	of text 	will scroll by. It should finish similar to this


5. In your web browser, open a new tab and navigate to 	`http://<ducp-0 public IP>:8000/` You should see the Dockercoins UI 

	**Note***: Be sure to use HTTP not HTTPS*
		
5. In your web browser navigate back to the UCP server (`https://<ducp-0 public IP>`)

	Notice the dashboard now shows 1 application running. 
	
6. Click on the menu icon and select `applications` from the drop down. 

	![Menu](images/menu.png)
	
7. List out all the running containers by clicking `Show` on the line listing the Dockercoins application

	![Show Containers](images/show.png)
	
	Notice that from here you control the container state (stop, restart, start) as well as 	delete a container. 

8. Click `inspect` next to the dockercoins_rng container

	This shows us the details of the running container. We can also control container state 	here. Aditionally we can scale out a given container. 
	
10. Notice how the menu bar allows you to see performance stats, logs, and even open a console window into the container. Feel free to explore these options. 

	![Container Menu](images/container_menu.png)
	
	





		


	

		
		
	
	
 


	