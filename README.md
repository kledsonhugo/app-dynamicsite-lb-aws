# Lab de uso do AWS EC2 com Load Balancer

O objetivo desta atividade é explorar na prática os conceitos de comptação em nuvem utilizando os serviços **AWS Elastic Compute Cloud (EC2)** e **AWS EC2 Elastic Load Balancing**.

O Amazon EC2 pode ser utilizado para hospedar quaisquer aplicações, tais como aplicações web, aplicações MiddleWare, aplicações de banco de dados, jogos, aplicações empresariais, entre outras.

O Elastic Load Balancing (ELB) distribui automaticamente o tráfego de aplicações de entrada entre vários destinos e dispositivos virtuais em uma ou mais Zonas de disponibilidade (AZs).

Referências
- [https://aws.amazon.com/pt/ec2/](https://aws.amazon.com/pt/ec2/)
- [https://aws.amazon.com/pt/elasticloadbalancing/](https://aws.amazon.com/pt/elasticloadbalancing/)

<br>

## **Arquitetura alvo**

![Architecture](/images/architecture.jpg)

<br>

## **Passo-a-passo**

01. Faça login no AWS Console.

<br>

### **Virtual Private Cloud (Rede)**

02. Em **Serviços** selecione **VPC**.

03. Selecione o botão **Criar VPC**.

04. Na tela de criação de VPC preencha com as informações abaixo e no final da tela clique em  **Criar VPC**.
  
    - **VPC e muito mais**
    - **Gerar automaticamente**: desabilitado
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
    
    <br>

    > **Note**: Mantenha as demais opções padrões.

    > **Note**: Guarde o ID da VPC pois será utilizado à frente.

<br>

### **EC2 Security Group (Firewall)**

05. Em **Serviços** selecione **EC2**.

06. No menu lateral esquerdo, selecione **Security Groups**.

07. Clique no botão **Criar grupo de segurança**.

08. Na tela de criação do Grupo de Segurança preencha com as informações abaixo e no final da tela clique em  **Criar Grupo de Segurança**.
  
    - **Nome do grupo de segurança**: sgappsiteec2elb
    - **Descrição**: Security Group for app-site-ec2-elb
    - **VPC**: Selecione o ID da VPC que você criou no passo 04
    - **Regras de Entrada**
      - Clique em **Adicionar Regra** para cada regra abaixo
        - Regra Ingress: VPC all
          - **Tipo**: Todo o Tráfego
          - **Origem**: 10.0.0.0/16
        - Regra Ingress: All ssh
          - **Tipo**: SSH
          - **Origem**: 0.0.0.0/0
        - Regra Ingress: All http
          - **Tipo**: HTTP
          - **Origem**: 0.0.0.0/0

    <br>

    > **Note**: Mantenha as demais opções padrões.

    > **Note**: Guarde o ID do Grupo de Segurança pois será utilizado mais à frente.

<br>

### **EC2 Instances (Máquinas Virtuais)**

<br>

#### **Máquina Virtual na Zona de Disponibilidade us-east-01a**

09. Em **Serviços** selecione **EC2**.

10. No menu lateral esquerdo, selecione **Instâncias**.

11. Selecione o botão **Executar instância**.

12. No campo **Nome** preencha com **app-site-ec2-elb-01a**.

13. Na seção **Par de chaves (login)** selecione a chave **vockey** ou crie uma chave de segurança de sua preferência.

14. Na seção **Configurações de Rede** clique em **Editar** e preencha com as informações abaixo.

    - **VPC**: Selecione a vpc que você criou no passo 04
    - **Sub-rede**: Selecione a Sub-rede na Zona de disponibilidade us-east-01a
    - **Atribuir IP público automaticamente**: Habilitar
    - **Firewall (grupos de segurança)**: Selecionar grupo de segurança existente
    - **Grupos de segurança comuns**: sgappsiteec2elb
    - Em **Detalhes avançados**, adicione o conteúdo abaixo no campo **Dados do usuário - optional**

      ```
      #!/bin/bash

      echo "Update/Install required OS packages"
      yum update -y
      dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel telnet tree git

      echo "Deploy PHP info app"
      cd /tmp
      git clone https://github.com/kledsonhugo/app-site-ec2-elb
      cp /tmp/app-site-ec2-elb/app/phpinfo.php /var/www/html/index.php
      rm -rf /tmp/app-site-ec2-elb

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

15. Clique em **Executar instância**.

    > **Note**: Guarde o ID da instância EC2 pois será utilizado mais à frente.

16. Clique em **Visualizar instâncias**.

<br>

#### **Máquina Virtual na Zona de Disponibilidade us-east-01b**

17. Em **Serviços** selecione **EC2**.

18. No menu lateral esquerdo, selecione **Instâncias**.

19. Selecione o botão **Executar instância**.

20. No campo **Nome** preencha com **app-site-ec2-elb-01b**.

21. Na seção **Par de chaves (login)** selecione a chave **vockey** ou crie uma chave de segurança de sua preferência.

22. Na seção **Configurações de Rede** clique em **Editar** e preencha com as informações abaixo.

    - **VPC**: Selecione a vpc que você criou no passo 04
    - **Sub-rede**: Selecione a Sub-rede na Zona de disponibilidade us-east-01b
    - **Atribuir IP público automaticamente**: Habilitar
    - **Firewall (grupos de segurança)**: Selecionar grupo de segurança existente
    - **Grupos de segurança comuns**: sgappsiteec2elb
    - Em **Detalhes avançados**, adicione o conteúdo abaixo no campo **Dados do usuário - optional**

      ```
      #!/bin/bash

      echo "Update/Install required OS packages"
      yum update -y
      dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel telnet tree git

      echo "Deploy PHP info app"
      cd /tmp
      git clone https://github.com/kledsonhugo/app-site-ec2-elb
      cp /tmp/app-site-ec2-elb/app/phpinfo.php /var/www/html/index.php
      rm -rf /tmp/app-site-ec2-elb

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

23. Clique em **Executar instância**.

    > **Note**: Guarde o ID da instância EC2 pois será utilizado mais à frente.

24. Clique em **Visualizar instâncias**.

<br>

#### **Validação de integridade das Máquinas Virtuais EC2**

25. Verifique as instâncias na lista e aguarde até que o campo **Verificação de status** esteja com o texto **2/2 verificações aprovadas**.

    > **Note**: A cada 1 minuto você pode atualizar a página para acompanhar a evolução da **Verificação de status**.

<br>

### **EC2 Load Balancer**

<br>

#### **Grupo de Destino**

26. Em **Serviços** selecione **EC2**.

27. No menu lateral esquerdo, selecione **Grupos de Destino**.

28. Selecione o botão **Criar grupo de destino**.

29. Na seção **Especificar detalhes do grupo** preencha com as informações abaixo e clique em **Próximo**.

    - **Instâncias**: Selecionado
    - **Nome do grupo de destino**: grupo-app-site-ec2-elb
    - **VPC**: Selecione o ID da VPC que você criou no passo 04

    <br>

30. Na seção **Registrar destinos** preencha com as informações abaixo e clique em **Incluir como pendente abaixo**.

    - **Instâncias disponíveis**: Selecione os IDs das instâncias EC2 que você criou nos passos 15 e 23.

    <br>

30. Clique em **Criar grupo de destino**.

<br>

#### **Balanceador de Carga**

31. Em **Serviços** selecione **EC2**.

32. No menu lateral esquerdo, selecione **Load Balancer**.

33. Clique no botão **Criar load balancer**.

34. Selecionar **Application Load Balancer** e clique no botão **Criar**. 

35. Na seção **Criar Application Load Balancer** preencha com as informações abaixo e clique em **Criar load balancer**.

    - **Nome do load balancer**: lb-app-site-ec2-elb
    - **VPC**: Selecione o ID da VPC que você criou no passo 04
    - **Mapeamentos**: Selecione as Zonas de Disponibilidade us-east-1a e us-east-1b
    - **Grupo de segurança**: sgappsiteec2elb
    - **Listeners e roteamento**
      - **Ação padrão**: Avançar para grupo-app-site-ec2-elb
    
    <br>

36. Clique em **Ver balanceador de carga**.

37. Verifique seu balanceador de carga na lista e aguarde até que o campo **Estado** esteja com o texto **Active**, conforme a figura.

    ![AWS Load Balancer State](/images/load_balancer.jpg)

38. Selecione o balanceador de carga na lista e copie o valor do campo **Nome do DNS**.

39. Abra uma nova aba do seu navegador e acesse a url capturada no passo anterior.

<br>

### **Validação de sucesso**

40. Para o sucesso desse lab, você deverá visualizar uma página conforme o exemplo abaixo. Ao atualizar o browser, as informações da primeira linha **System** deverão alterar conforme o direcionamento do balanceador de carga para uma máquina virtual EC2 diferente, conforme as duas imagens de exemplo abaixo.

    - Máquina Virtual na zona de disponibilidade **us-east-1a**
      ![AWS Load Balancer Instance 1a](/images/load_balancer-instance_1a.jpg)

    - Máquina Virtual na zona de disponibilidade **us-east-1b**
      ![AWS Load Balancer Instance 1b](/images/load_balancer-instance_1b.jpg)

    <br>

    > **Note**: Caso a págna não carregue após 5 minutos, refaça os passos do lab desde o início com cautela.

41. Caso esteja utilizando um ambiente pago, não esqueça de destruir os recursos criados para evitar custos indesejados.