# Прочтите данное сообщение перед использование.

**1. Скрипты для роутеров ВВОДИТЬ РУЧКАМИ, скопировал вставил. Это легче чем использовать TFTP.**

**2. Вам нужно использовать скрипты на виртуальных маших отдельно и  нужно настраивать все постепенно: ISP, RTRы, Серверы и клиент**

**3.Чтобы использовать данный скрипт нужно выполнить одну команду:**

```apt-get update -y && apt-get install git -y && git clone https://github.com/OOTSOSI/demo25 && cd demo25/ && chmod +x ISP.sh && sh ISP.sh```
```apt-get update -y && apt-get install git -y && git clone https://github.com/OOTSOSI/demo25 && cd demo25/ && chmod +x HQ-SRV.sh && sh HQ-SRV.sh```
```apt-get update -y && apt-get install git -y && git clone https://github.com/OOTSOSI/demo25 && cd demo25/ && chmod +x BR-SRV.sh && sh BR-SRV.sh```

**А далее вы уже выбираете нужный вам скрипт даете права на его выполнение и применяете: chmod +x X.sh && sh X.sh, где Х это назавание нужного вам скрипта**
<br/>

<br/>
<p align="center">
  <img src="scheme.jpg"
<p\>
<p align="center"><strong>Топология</strong></p>
<br/>

<br/>
