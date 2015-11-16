Manipulação de dados meteorológicos com R (Resbmet)
========================================================
width: 1440
height: 900
transition: none
font-family: 'Helvetica'
css: my_style.css
author: Jonatan Tatsch, UFSM
date: Santa Maria, 16, Nov de 2015

</style>
<div class="midcenter" style="margin-left:250px; margin-top:-50px;">
<img src="figs/logos.png" height="600px" width="1000px" />
</div>

Facilitadores
=======================
<br/>
### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Roilan Valdés (Mestrando PPGMET-UFSM)]()
<br/>
#### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Nelson Navarrete (Pós-Doc PPGMET-UFSM)
<br/>
#### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Guilherme Goergen (Doutorando PPGMET-UFSM)


Introdução
=======================
<br/>
## Análise de dados meteorológicos 
<br/> 
<br/>
<br/>
> <span style="color:black; font-size:1.25em;">Processo pelo qual adquire-se conhecimento, compreensão e percepção dos fenômenos meteorológicos a partir de observações (dados) qualitativas e quantitativas.</span>

<br/>
<br/>
<br/>

Etapas para abordagem de um problema
=======================

 1. **Questão científica/problema**
<br/>
 2. **Obtenção de dados:** coleta/medida do(as) estado/condições da atmosfera
    - Instrumentos e sensores
<br/>
 3. **Tratamento de dados:**
    *download* ---> limpeza ---> formatação ---> <br/>
     transformação ---> controle de qualidade
       - ferramenta/software
         - <span style="color: red">conhecimento em programação</span>
<br/>
 4. **Análise de dados**
    - ferramenta/software
      - <span style="color: red">conhecimento em programação</span>
<br/>      
 5. **Proposta de um modelo** (estatístico, empírico, físicamente baseado)
<br/> 
 6. **Apresentação/divulgação/publicação/Relatório**



Programação computacional
=======================

</style>
<div class="midcenter" style="margin-left:80px; margin-top:50px;">
<img src="figs/mas_escolhas.jpg" height="600px" width="1200px" />
</div>

</style>
<div class="midcenter" style="margin-left:80px; margin-top:60px;">
<img src="figs/errando_aprende.png" height="100px" width="1100px" />
</div>

R
=======================
<br/>  
* Comunidade fantástica
<br/>  
* **Software Free**
<br/>  
* Código aberto
<br/>  
* Linguagem de Programação (intuitiva)
<br/>  
* **Ambiente para Análise de dados interativa**


Por que o R?
=======================
-  Acesso ao estado da arte em análise de dados
<br/>  
- Modelagem numérica, otimização
<br/>  
- Interface com Fortran, C, C++, Python
<br/>  
- Visualização de dados
<br/>  
- [Importação](https://github.com/hadley/readr) e [Manipulação de dados](http://blog.rstudio.org/2014/07/22/introducing-tidyr/)
<br/>  
- [Relatório dinâmicos](http://rmarkdown.rstudio.com/articles.html) e [interativos](http://shiny.rstudio.com/)

- **Existe grande chance de alguém já ter feito o modelo ou gráfico que você está querendo fazer**

- **Você poderá ir além, construir ou aperfeiçoar aquilo que já está livremente disponível**


Por que o R?
=======================

Ferramentas específicas para:

* dados espacias

* séries temporais

* importação e ferramentas de GIS

* leitura de dados em formatos específicos (netcdf, binários, ...)



Por que o R? 
=======================
<br/>  

(se quiser mais motivos ainda ... assista o vídeo abaixo)

<center>
[![Por que o R MeetUp R IME-USP](http://img.youtube.com/vi/UgPX49gkby4/0.jpg)](http://www.youtube.com/watch?v=UgPX49gkby4 "Video Title")
<center>



RStudio
=======

[RStudio](http://www.rstudio.com/) é um ambiente de desenvolvimento integrado livre e de código aberto. 

![RStudio IDE](http://www.rstudio.com/images/screenshots/rstudio-ubuntu.png)

-------------
- Para Windos, Linux e Mac
<br/>  
- ênfase da sintaxe do R, auto-preenchimento de código, identação inteligente
<br/>  
- execução do R diretamente do editor
<br/>  
- manejo de diretórios e projetos
<br/>  
- histórico de gráficos, zoom, atalhos para exportar imagens e PDF
<br/>  
- Integrado com Knitr
<br/>  
- Integrado com Git para controle de versões




Programação do curso
=======================

<br/>
## &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**Introdução ao Curso**
<br/>
## &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Instalando o R e o RStudio](https://rawgit.com/jdtatsch/Resbmet/master/0_Rinstall.html)
<br/>
## &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Dia 1: O Essencial sobre R
<br/>
## &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Dia 2: Manipulação de dados

Material do curso
=======================
<br/>
<br/>
<span style="color:black; font-size:1.25em;">Acesse https://github.com/jdtatsch/Resbmet</span>
