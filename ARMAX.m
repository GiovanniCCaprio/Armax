
clear all
clc
close all

w = simOptions('AddNoise',true);%gera o ruido a entrada 'u'
u = idinput(100,'rgs',[0 0.3]);%gera entrada com valores gaussianos

%%sistema ARMA (modelo ARMAX com Uk=0)

sistema = idpoly([1 0.7 0.1],[0],[1 0.4 0.05]); % sistema arma inicial sem controle
saida_arma = sim(sistema,u,w);% saída do sistema sem controle
valor = max(size(saida_arma));%valor maximo
Var_sc = sum(saida_arma.*saida_arma)/valor; % variância sem controle

par=0.0;%parâmetro da sequência de entrada exógena
a=0;b=0;c=0;
step=0.001; %aproximação do parametro
cont=0;%contador
l=5; %valor máximo do parametro

while (cont <= l)
    
    par = par+step; %parâmetro da sequência de entrada exógena
    

                       %sistemas ARMAX


%modelo ARMAX (com controle U(k-2))

sistema_armax1 = idpoly([1 0.7 0.1],[0 par],[1 0.4 0.03]);

yarmax1 = sim(sistema_armax1,u,w); % saída sistema controlado 2 passos a frente



%modelo ARMAX (com controle U(k-3))

sistema_armax2 = idpoly([1 0.7 0.1],[0 0 par],[1 0.4 0.03]);

yarmax2 = sim(sistema_armax2,u,w);% saída sistema controlado 3 passos a frente



valor = max(size(saida_arma));
 % Estimação das variâncias para as saídas
 Var_k2 = sum(yarmax1.*yarmax1)/valor; % Variância da saída 2 passos a frente
 Var_k3 = sum(yarmax2.*yarmax2)/valor; % Variância da saída 3 passos a frente
 
 
 
 if (par>=step)
          
     if Var_k2<b
        b=Var_k2;
        par_Uk2 = par;%parâmetro para o qual a variância do controle de
        % 2 passos a frente foi mínima
     end
     
     if Var_k3<c
         c=Var_k3;
         par_Uk3 = par;%parâmetro para o qual a variância do controle de
        % 3 passos a frente foi mínima
     end
 end
     
 if cont<step
    a = Var_sc; b = Var_k2; c = Var_k3;
 end
    
    cont = cont + step;
end

fprintf('\n Variância sistema sem controle: %0.3f', a);
fprintf('\n Variância sistema controlado y(k+2): %0.3f', b); 
fprintf('\n Parâmetro ótimo = %0.3f',par_Uk2);
fprintf('\n Variância sistema controlado y(k+3): %0.3f \n', c);
fprintf('\n Parâmetro ótimo = %0.3f',par_Uk3);
