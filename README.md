# Project: MATLAB Task  

## 1.check Stock

### Aim: Check LV stock state

### Method:  
 
> (1) using Crawler(webread)  

* Result: Return wrong JSON information (different with web browser) or delayed information.
    If add *User-agent*,unable to get web source. But using python script with user-agent, it still return wrong information.  

> (2) using the COM interface to control an internet explorer (IE)  

* Result: Working! Just like surfing with web with IE. Same result.  

*** 
