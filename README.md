# Lab de uso do AWS EC2 com Load Balancer

O objetivo desta atividade é explorar na prática os conceitos de computação em nuvem utilizando os serviços **AWS Elastic Compute Cloud (EC2)** e **AWS EC2 Elastic Load Balancing**.

O Amazon EC2 pode ser utilizado para hospedar quaisquer aplicações, tais como aplicações web, aplicações MiddleWare, aplicações de banco de dados, jogos, aplicações empresariais, entre outras.

O Elastic Load Balancing (ELB) distribui automaticamente o tráfego de aplicações de entrada entre vários destinos em uma ou mais Zonas de disponibilidade (AZs).

Referências
- [https://aws.amazon.com/pt/ec2/](https://aws.amazon.com/pt/ec2/)
- [https://aws.amazon.com/pt/elasticloadbalancing/](https://aws.amazon.com/pt/elasticloadbalancing/)

## **Arquitetura alvo**

![Architecture](/images/architecture.jpg)

## **Passo-a-passo**

### **Virtual Private Cloud (Rede)**

01. Faça login no AWS Console.

02. Em **Serviços** selecione **VPC**.

03. Selecione o botão **Criar VPC**.

04. Na tela de criação de VPC preencha com as informações abaixo.
  
    - **VPC e muito mais**
    - **Gerar automaticamente**: dynamicsite-lb
    - **Bloco CIDR IPv4**: 10.0.0.0/16
    - **Número de zonas de disponibilidade (AZs)**: 2
    - **Personalizar AZs**
      - **Primeira zona de disponibilidade**: us-east-1a
      - **Segunda zona de disponibilidade**: us-east-1b
    - **Número de sub-redes públicas**: 2
    - **Número de sub-redes privadas**: 0
    - **Personalizar blocos CIDR de sub-redes**
      - **Bloco CIDR da sub-rede pública em us-east-1a**: 10.0.1.0/24
      - **Bloco CIDR da sub-rede pública em us-east-1b**: 10.0.2.0/24
    - **Endpoints da VPC**: Nenhuma
    
    > **Note**: Mantenha as demais opções padrões e guarde o ID da VPC pois será utilizado à frente.

05. No final da tela clique em  **Criar VPC**.

### **EC2 Security Group (Firewall)**

01. Em **Serviços** selecione **EC2**.

02. No menu lateral esquerdo, selecione **Security Groups**.

03. Clique no botão **Criar grupo de segurança**.

04. Na tela de criação do Grupo de Segurança preencha com as informações abaixo.
  
    - **Nome do grupo de segurança**: dynamicsitelbsg
    - **Descrição**: Security Group dynamicsitelbsg
    - **VPC**: Selecione o ID da VPC que você criou anteriormente
    - **Regras de Entrada**
      - Clique em **Adicionar Regra** para cada regra abaixo
        - Regra 01
          - **Tipo**: Todo o Tráfego
          - **Origem**: 10.0.0.0/16
        - Regra 02
          - **Tipo**: SSH
          - **Origem**: 0.0.0.0/0
        - Regra 03
          - **Tipo**: HTTP
          - **Origem**: 0.0.0.0/0

    > **Note**: Mantenha as demais opções padrões e guarde o ID do Grupo de Segurança pois será utilizado mais à frente.

04. No final da tela clique em  **Criar Grupo de Segurança**.

### **EC2 Instances (Máquinas Virtuais)**

#### **Máquina Virtual na Zona de Disponibilidade us-east-1a**

01. Em **Serviços** selecione **EC2**.

02. No menu lateral esquerdo, selecione **Instâncias**.

03. Selecione o botão **Executar instância**.

04. No campo **Nome** preencha com **dynamicsite-lb-ec2-1a**.

05. Na seção **Par de chaves (login)** selecione a chave **vockey** ou crie uma chave de segurança de sua preferência.

06. Na seção **Configurações de Rede** clique em **Editar** e preencha com as informações abaixo.

    - **VPC**: Selecione a vpc que você criou anteriormente
    - **Sub-rede**: Selecione a Sub-rede na Zona de disponibilidade us-east-1a
    - **Atribuir IP público automaticamente**: Habilitar
    - **Firewall (grupos de segurança)**: Selecionar grupo de segurança existente
    - **Grupos de segurança comuns**: Selecione a Security Group que você criou anteriormente
    - Em **Detalhes avançados**, adicione o conteúdo abaixo no campo **Dados do usuário - optional**

      ```
      #!/bin/bash

      echo "Update/Install required OS packages"
      yum update -y
      dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel telnet tree git

      echo "Deploy PHP info app"
      cd /tmp
      git clone https://github.com/kledsonhugo/app-dynamicsite
      cp /tmp/app-dynamicsite/phpinfo.php /var/www/html/index.php

      echo "Config Apache WebServer"
      usermod -a -G apache ec2-user
      chown -R ec2-user:apache /var/www
      chmod 2775 /var/www
      find /var/www -type d -exec chmod 2775 {} \;
      find /var/www -type f -exec chmod 0664 {} \;

      echo "Start Apache WebServer"
      systemctl enable httpd
      service httpd restart
      ```

    > **Note**: Mantenha as demais opções padrões. 

07. Clique em **Executar instância**.

    > **Note**: Guarde o ID da instância EC2 pois será utilizado mais à frente.

#### **Máquina Virtual na Zona de Disponibilidade us-east-1b**

01. Em **Serviços** selecione **EC2**.

02. No menu lateral esquerdo, selecione **Instâncias**.

03. Selecione o botão **Executar instância**.

04. No campo **Nome** preencha com **dynamicsite-lb-ec2-1b**.

05. Na seção **Par de chaves (login)** selecione a chave **vockey** ou crie uma chave de segurança de sua preferência.

06. Na seção **Configurações de Rede** clique em **Editar** e preencha com as informações abaixo.

    - **VPC**: Selecione a vpc que você criou anteriormente
    - **Sub-rede**: Selecione a Sub-rede na Zona de disponibilidade us-east-1b
    - **Atribuir IP público automaticamente**: Habilitar
    - **Firewall (grupos de segurança)**: Selecionar grupo de segurança existente
    - **Grupos de segurança comuns**: Selecione a Security Group que você criou anteriormente
    - Em **Detalhes avançados**, adicione o conteúdo abaixo no campo **Dados do usuário - optional**

      ```
      #!/bin/bash

      echo "Update/Install required OS packages"
      yum update -y
      dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel telnet tree git

      echo "Deploy PHP info app"
      cd /tmp
      git clone https://github.com/kledsonhugo/app-dynamicsite
      cp /tmp/app-dynamicsite/phpinfo.php /var/www/html/index.php

      echo "Config Apache WebServer"
      usermod -a -G apache ec2-user
      chown -R ec2-user:apache /var/www
      chmod 2775 /var/www
      find /var/www -type d -exec chmod 2775 {} \;
      find /var/www -type f -exec chmod 0664 {} \;

      echo "Start Apache WebServer"
      systemctl enable httpd
      service httpd restart
      ```

    > **Note**: Mantenha as demais opções padrões.

07. Clique em **Executar instância**.

    > **Note**: Guarde o ID da instância EC2 pois será utilizado mais à frente.

#### **Validação de integridade das Máquinas Virtuais EC2**

01. Em **Serviços** selecione **EC2**.

02. No menu lateral esquerdo, selecione **Instâncias**.

03. Verifique na lista pelo ID das instâncias que você criou anteriormente e aguarde até que o campo **Verificação de status** esteja com o texto **2/2 verificações aprovadas**.

    > **Note**: A cada 1 minuto você pode atualizar a página para acompanhar a evolução da **Verificação de status**.

### **EC2 Load Balancer**

#### **Grupo de Destino**

01. Em **Serviços** selecione **EC2**.

02. No menu lateral esquerdo, selecione **Grupos de Destino**.

03. Selecione o botão **Criar grupo de destino**.

04. Na seção **Especificar detalhes do grupo** preencha com as informações abaixo.

    - **Instâncias**: Selecionado
    - **Nome do grupo de destino**: dynamicsite-lb-tg
    - **VPC**: Selecione o ID da VPC que você criou anteriormente

05. Clique em **Próximo**.

06. Na seção **Registrar destinos** selecione os IDs das instâncias EC2 que você criou anteriormente e clique em **Incluir como pendente abaixo**.

06. Clique em **Criar grupo de destino**.

#### **Balanceador de Carga**

01. Em **Serviços** selecione **EC2**.

02. No menu lateral esquerdo, selecione **Load Balancers**.

03. Clique no botão **Criar load balancer**.

04. Para o tipo **Application Load Balancer**,  clique no botão **Criar**. 

05. Na seção **Criar Application Load Balancer** preencha com as informações abaixo.

    - **Nome do load balancer**: dynamicsite-lb
    - **VPC**: Selecione o ID da VPC que você criou anteriormente
    - **Mapeamentos**: Selecione as Zonas de Disponibilidade us-east-1a e us-east-1b
    - **Grupo de segurança**: Remova o Grupo de Segurança default e selecione o Grupo de Segurança que você criou anteriormente
    - **Listeners e roteamento**
      - **Ação padrão**: Avançar para dynamicsite-lb-tg

06. Clique em **Criar load balancer**.

07. Verifique seu balanceador de carga na lista e aguarde até que o campo **Estado** esteja com o texto **Active**.

    > **Note**: A cada 1 minuto você pode atualizar a página para acompanhar a evolução.

08. Copie o valor do campo **Nome do DNS**.

09. Abra uma nova aba do seu navegador e acesse a url **http://[NOME DO DNS]**.

### **Validação de sucesso**

01. Para o sucesso desse lab, você deverá visualizar uma página conforme o exemplo abaixo. Ao atualizar o browser, as informações da primeira linha **System** deverão alterar conforme o direcionamento do balanceador de carga para uma máquina virtual EC2 diferente, conforme as duas imagens de exemplo abaixo.

    - Máquina Virtual na zona de disponibilidade **us-east-1a**
      ![AWS Load Balancer Instance 1a](/images/load_balancer-instance_1a.jpg)

    - Máquina Virtual na zona de disponibilidade **us-east-1b**
      ![AWS Load Balancer Instance 1b](/images/load_balancer-instance_1b.jpg)

### **Destruição dos recursos**

01. Não esqueça de destruir os recursos criados para evitar custos indesejados.