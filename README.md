# How  to deploy a Machine Learning Model WebApp on AWS Cloud SageMaker Notebook

Sometimes when you need to deploying **machine learning models** in **production** and **graphics-intensive applications** and you have not enough power computing to satisfy your needs. Then you can use the following blog post to solve this issue. Instead of upgrade your  cluster of your company or personal computer, you can use the cloud. 

With **Amazon Web Services** you can simply  create an instance with the adequate requirements for your Web Application .

In this blog post I will show how to create a web application on **AWS SageMaker** Notebook and connect with from your computer.

In particular we will create an application that will create a **video from a text** by using one of the amazing techniques to generation of images from a text by using **DALL-E**.

The video that I am interested to create is about the **The Hare & the Tortoise** and the  **Selfish Giant**, I am going to create a WebApplication that will create from the text a video story based on the experienced that the machine learning model has.





The model that I will consider is the **DALL-E**  , it is machine learning models developed by OpenAI to generate digital images from  natural language descriptions.  Let me mention that there is now a new  version called **DALL-E 2**   which is designed  to generate more realistic images at higher resolutions that "can combine concepts, attributes, and styles

<img src="assets/images/posts/README/dalle2.jpg" alt="dalle2" style="zoom:50%;" />



**DALLE -2** Generated this image when given the prompt "Teddy bears working on new AI research underwater with 1990s technology".

(Picture from Wikipedia)

## Architecture

AWS does not natively support SSH-ing into **SageMaker notebook instances**, but nothing really prevents you from setting up SSH yourself.

There are two  possible solutions to connect :

a) **Reverse proxy**

b) **Bastion box.**  

In a previous blog post we have discussed the [ How to connect to Sagemaker via SSH](https://ruslanmv.com/blog/How-to-connect-to-Sagemaker-Notebook-via-SSH), which is based on the **Bastion box**. This is useful when you want to control all the pieces of your Cloud Infrastructure. In this new blog post we focus in a more simpler solution that is given by the **Reverse proxy.**

# Reverse proxy Solution

A **reverse proxy** is a type of proxy server.  Unlike a traditional proxy server, which is used to protect clients, a reverse proxy is used to protect servers. A reverse proxy is a server that accepts a request from a client, forwards the request to another one of many other servers, and returns the results from the server that actually processed the request to the client as if the proxy server had processed the request itself. The client only communicates directly with the reverse proxy server and it does not know that some other server actually processed its request.

![](assets/images/posts/README/Sagemaker-Ngrok.png)

Due to **AWS Sagemaker** notebook officially does not support **ssh** support natively and we want to connect from our Laptop to our Sagemaker Server. We are going to a use a simply application called  **ngrok**  that will allow us connect it to our server.

## Step 1 - Creation of ngrok Account



First create account on [https://ngrok.com/signup]( https://ngrok.com/signup)

[![image-20220827200836580](assets/images/posts/README/image-20220827200836580.png)]( https://ngrok.com/signup)

after you created your account  and confirm your email, you can copy the **Authtoken**

![image-20220827201513724](assets/images/posts/README/image-20220827201513724.png)

you will use this Token to get the URL site of your web applications.

## Step 2- Creation of Security Group for SageMaker

In ordering to communicate with Sagemaker Notebook Instance we need create a custom  **Security Groups**.

Head to the [AWS Console](https://aws.amazon.com/console/) and from there, under  All Services, choose **EC2**, open a new tab

![f](assets/images/posts/README/image-20220824001332277.png)

in the new window , click **Security Groups**

![image-20220824001439396](assets/images/posts/README/image-20220824001439396.png)

and then **Create Security Group**. Give it a name, such as **SageMaker-Security**, and then create an SSH rule to only allow the my IP in the inboud



![](assets/images/posts/README/SG1.png)

and outbout **Anywhere**

![](assets/images/posts/README/SG2.png)

once was created we can continue to create a new SageMaker notebook.



### Step 3 - Creation of SageMaker Notebook

Head to the [AWS Console](https://aws.amazon.com/console/) and from there, under  All Services, choose **SageMaker**. 

![image-20220823232801530](assets/images/posts/README/image-20220823232801530.png)



In Sagemaker we will choose the Notebook instances, click **create a notebook instance**

![image-20220823234016378](assets/images/posts/README/image-20220823234016378.png)



then we name our server as **Sagemaker** . There are a vast of types of AWS Instaces, for our GPU consuming   I suggest use the Amazon EC2 G4 instances that  provide the latest generation **NVIDIA T4 GPUs**.

Moreover **Amazon EC2 G4 instances** deliver a cost-effective GPU instance for deploying machine learning models in production and graphics-intensive applications. 

These instances deliver up to 65 TFLOPs of FP16 performance to accelerate machine learning inference applications and ray-tracing cores to accelerate graphics workloads such as graphics workstations, video transcoding, and game streaming in the cloud.



**You should be careful,** choose the appropriate instance, to avoid extra costs!!!

| Accelerated Computing | vCPU | Memory  | Price per Hour |
| :-------------------: | :--: | :-----: | :------------: |
|     ml.p3.2xlarge     |  8   | 61 GiB  |     $3.825     |
|     ml.p3.8xlarge     |  32  | 244 GiB |    $14.688     |
|    ml.p3.16xlarge     |  64  | 488 GiB |    $28.152     |
|    ml.g4dn.xlarge     |  4   | 16 GiB  |    $0.7364     |
|    ml.g4dn.2xlarge    |  8   | 32 GiB  |     $0.94      |

In particular this instance **ml.g4dn.2xlarge**   , during the writing time, you will pay **$0.94 per Hour** so  be sure to delete your Instance after you finish.

In the **Notebook instance settings**, we name the instance as **Sagemaker** and Notebook Instance **ml.g4dn.2xlarge**  we need to add  an extra **Volume Size** of the instance, for this project we choose **30gb**.

![image-20220829180729972](assets/images/posts/README/image-20220829180729972.png)

 In the **Network section**, we choose our **Default VPC** and we choose the first subnet that you can see then, in the Security Group we select **SageMaker-Security** 

![image-20220828215101584](assets/images/posts/README/image-20220828215101584.png)

and finally **create the notebook instance** and we wait until the Status changes from **Pending** to **InService.**

![image-20220824224136683](assets/images/posts/README/image-20220824224136683.png)



## Step 3 - Setup Sagemaker Notebook

Click **Open Jupyter Lab**  and  click **File** > **New**>**Terminal**

![image-20220828192113741](assets/images/posts/README/image-20220828192113741.png)



then in the terminal type

```
source activate python3
```

and there you can  type

```
conda info --envs
```

to see all your possible enviroments by defult given in SageMaker

![image-20220828192231098](assets/images/posts/README/image-20220828192231098.png)

For this project, we are going to use  `pytorch_p38`

```
conda activate pytorch_p38
```

If you decided use Jupyter insted JupyterLab you skip the following code:

and we install pyngrok  to get the reverse proxy  and gradio to test the enviroment

```
pip install pyngrok gradio
```

![image-20220828220430504](assets/images/posts/README/image-20220828220430504.png)



## Step 4 - Setup pyngrok

Let us open a new notebook 

![image-20220828220454086](assets/images/posts/README/image-20220828220454086.png)



and we select the kernel  **pytorch_p38** and name it with **reverse_proxy**

![image-20220828220558412](assets/images/posts/README/image-20220828220558412.png)



then create new text file

![image-20220829175217082](assets/images/posts/README/image-20220829175217082.png)

that your rename to  **data.json**

with your personal token, for example

```
{
    "token": "2DwxLpbhkdalskdalskjdalksjdlakjdlakjwcgL3Z2KtUz11"
}
```

then for the notetbook r**everse_proxy** copy the following code:

```python
#Setup of your token for first time
import sys, IPython
from pyngrok import ngrok
import json 
# Opening JSON file
f = open('data.json')
# returns JSON object as 
# a dictionary
data = json.load(f)
#print(data)
YOUR_TOKEN=data['token']
ngrok.set_auth_token(YOUR_TOKEN)
IPython.Application.instance().kernel.do_shutdown(True)
```

then  you can run

```python
# If is installed the token you can use this code
import sys, IPython
from pyngrok import ngrok
from IPython.core.display import display, HTML
# Open a HTTP tunnel on port 7860
# <NgrokTunnel: "http://<public_sub>.ngrok.io" -> "http://localhost:7860">
http_tunnel = ngrok.connect(7860, bind_tls=True)
http_url = http_tunnel.public_url
display(HTML(f'<b><a target="blank" href="{http_url}">Load test: {http_url}</a></b>'))
```

You will have something similar like:

**[Load test: https://1ce4-34-236-55-223.ngrok.io](https://1ce4-34-236-55-223.ngrok.io/)**

```python
# Open a SSH tunnel
# <NgrokTunnel: "tcp://0.tcp.ngrok.io:12345" -> "localhost:22">
ssh_tunnel = ngrok.connect(22, "tcp")
display(HTML(f'<b><a target="blank" href="{ssh_tunnel}">SSH test: {ssh_tunnel}</a></b>'))
```

You will have something similar like:

**["localhost:22"">SSH test: NgrokTunnel: "tcp://8.tcp.ngrok.io:12995" -> "localhost:22"](ngroktunnel:)**

you can see your status

```python
tunnels = ngrok.get_tunnels()
print(tunnels)
```

and the output is

```
[<NgrokTunnel: "https://1ce4-34-236-55-223.ngrok.io" -> "http://localhost:7860">, <NgrokTunnel: "tcp://8.tcp.ngrok.io:12995" -> "localhost:22">]
```



## Step 5 Testing Environment

Now create a new notebook called  **hello_world,** you can add the following code

```python
import gradio as gr
def test():
    def greet(name):
      return "Hello " + name + "!"
    iface = gr.Interface(fn=greet, inputs="text", outputs="text")
    iface.launch(server_port=7860)
```

then

```
test()
```

After is running this  return back to your reverse_proxy notebook and open the link

**[https://1ce4-34-236-55-223.ngrok.io](https://1ce4-34-236-55-223.ngrok.io/)**

and type your name for example,

![image-20220829000107971](assets/images/posts/README/image-20220829000107971.png)Dont worry if 

If Chrome says: Deceptive site ahead Attackers on **8c5c-34-236-55-223.ngrok.io** ... dont worry. You click visit this site.

Somehow Chrome marked ngrok.io like a dangerous, to avoid this type of issues you can select another method to log into SageMaker,  like in previous blog  [ How to connect to Sagemaker via SSH](https://ruslanmv.com/blog/How-to-connect-to-Sagemaker-Notebook-via-SSH).

If your you pass the test, then 

you can close gradio

```python
msg = 'Would you like stop gradio server?'
shall = input("%s (y/N) " % msg).lower() == 'y'
if shall == True:
    print(" Shutting down gradio server.")
    gr.close_all()
```

by pressing y

```
Would you like stop gradio server? (y/N)  y
 Shutting down gradio server.
Closing server running on port: 8089
```



## Ngrok in the terminal (optional)

For complementary you can use also the terminal to use ngrok

```
 ngrok authtoken YOUR_TOKEN_HERE
```

and

```
ngrok http 8089
```

![image-20220825224717789](assets/images/posts/README/image-20220825224717789.png)



when you click ctrl+c, the server is stoped, but we wont use the ngrok in the terminal.



# Creation of Awesome Video Story - Text to Video 



Finally  we have built all the Infrastructure in the cloud needed to create our amazing video story.

Open a new terminal. To install the Python packages in the correct Conda environment, first activate the environment before running **pip install** or **conda install** from the terminal.

```
sh-4.2$ source activate python3
```

To activate any conda environment, run the following command in the terminal.

```
(python3) sh-4.2$ conda activate pytorch_p38
```

When you run this command, any packages installed using conda or pip are installed in the environment.

Let us clone the repostory, enter to **Sagemaker** folder

```
cd Sagemaker
```

then

```
git clone https://github.com/ruslanmv/Text-to-Video-Story.git
```

```
cd Text-to-Video-Story
```

```
cd sagemaker
```

```
pip install -r requirements.txt
```

you will obtain something like

![image-20220829170233221](assets/images/posts/README/image-20220829170233221.png)

after all the requirements well installed. Let us use **Jupyter**.

Now let us open  **Jupyter**

![image-20220829170332633](assets/images/posts/README/image-20220829170332633.png)

then we choose **video_story_creator_gradio**

![image-20220829170533099](assets/images/posts/README/image-20220829170533099.png)



you run the first cell

```python
# Step 2 - Importing Libraries
from moviepy.editor import *
from PIL import Image
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM,pipeline
import gradio as gr
import torch
from huggingface_hub import snapshot_download
from PIL import Image
from min_dalle import MinDalle
import torch
from PIL import Image, ImageDraw, ImageFont
import textwrap
from mutagen.mp3 import MP3
# to speech conversion
from gtts import gTTS
from pydub import AudioSegment
from os import getcwd
import glob
import nltk
import subprocess
nltk.download('punkt')
description = " Video Story Generator with Audio \n PS:  Generation of video by using Artifical Intellingence by dalle-mini and distilbart and gtss "
title = "Video Story Generator with Audio by using dalle-mini and distilbart and gtss  "
tokenizer = AutoTokenizer.from_pretrained("sshleifer/distilbart-cnn-12-6")
model = AutoModelForSeq2SeqLM.from_pretrained("sshleifer/distilbart-cnn-12-6")
```

and then

```python
# Analsis of GPU usage
def log_gpu_memory():
    print(subprocess.check_output('nvidia-smi').decode('utf-8'))
device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
print(device)
use_gpu = True if torch.cuda.is_available() else False
if use_gpu == True : log_gpu_memory() 
#transfer model
#model.to(device)
```

![image-20220829171000145](assets/images/posts/README/image-20220829171000145.png)

You can see that we have a Great **Tesla T4** GPU.

Run the next shell

![image-20220829171251772](assets/images/posts/README/image-20220829171251772.png)

and later you can enter to your url, like mine

**[Load test: https://6119-34-236-55-223.ngrok.io](https://6119-34-236-55-223.ngrok.io/)**

and will open

![image-20220829171810185](assets/images/posts/README/image-20220829171810185.png)

when you click Generate Video, in your notebook you can see the progress
