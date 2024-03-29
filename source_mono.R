#### func.mL ####
func.mL = function(vet, # Vetor de entrada Binário
                   obj_cm = TRUE, # objetivo custo medio
                   obj_propnc = FALSE, # objetivo custo medio nao conforme un produzida
                   func_m = FALSE, # Utilizar função m (m = L)
                   
                   # Parametros probabilisticos
                   p1 = 0.999,
                   p2 = 0.95,
                   pi = 0.0001,
                   alpha = 0.01,
                   
                   # Parametros de Custo
                   c_i = 0.25,
                   c_nc = 20,
                   c_a = 100,
                   c_s = 2,
                   
                   penalidade_CM = 5
                   )
{
  # Erro de entrada
  if (!obj_cm){
    if (!obj_propnc){
      stop("Tem de escolher pelo menos um objetivo!")
    }
  }
  
  # Definicao dos Parametros
  
  ## Parametros Probabilísticos do Processo
  #p1 = Fracao de conformes processo sobre controle
  #p2 = Fracao de Conformes processo fora de controle
  #pi = Probabilidade de ocorrencia de shift
  #alpha = Probabilidade de classificacao nao cfe em item cfe
  # beta = Probabilidade de classificacao cfe em item nao cfe
  
  ## Parametros de custo
  #c_i = Custo de inspecao
  #c_nc = Custo envio de nao conformidade
  #c_a = Custo de ajuste
  #c_s = Custo de descarte de peca inspecionada
  
  beta = alpha
  
  # Decodificando Parametros de entrada
  
  if (func_m){
    
    m = L = GA::binary2decimal(vet)
    
  }else{
    
    m = GA::binary2decimal( vet[1:8] )
    L = GA::binary2decimal( vet[ 9:length(vet) ] )
    
  }
  
  # Contrucao da Matriz de Transicao e Calculo do Vetor Estacionario
  
  P = matrix(rep(0,36), nrow = 6)
  
  P[1,1]=(1-pi)^m*(p1*(1-alpha)+(1-p1)*beta)
  P[1,2]=(1-pi)^m*(p1*alpha+(1-p1)*(1-beta))
  P[1,3]=(1-(1-pi)^m)*(p2*(1-alpha)+(1-p2)*beta)
  P[1,4]=(1-(1-pi)^m)*(p2*alpha+(1-p2)*(1-beta))
  P[1,5]=0
  P[1,6]=0
  
  P[2,1]=(1-pi)^L*(p1*(1-alpha)+(1-p1)*beta)
  P[2,2]=(1-pi)^L*(p1*alpha+(1-p1)*(1-beta))
  P[2,3]=(1-(1-pi)^L)*(p2*(1-alpha)+(1-p2)*beta)
  P[2,4]=(1-(1-pi)^L)*(p2*alpha+(1-p2)*(1-beta))
  P[2,5]=0
  P[2,6]=0
  
  P[3,1]=0
  P[3,2]=0
  P[3,3]=0
  P[3,4]=0
  P[3,5]=(p2*(1-alpha)+(1-p2)*beta)
  P[3,6]=(p2*alpha+(1-p2)*(1-beta))
  
  P[4,1]=(1-pi)^L*(p1*(1-alpha)+(1-p1)*beta)
  P[4,2]=(1-pi)^L*(p1*alpha+(1-p1)*(1-beta))
  P[4,3]=(1-(1-pi)^L)*(p2*(1-alpha)+(1-p2)*beta)
  P[4,4]=(1-(1-pi)^L)*(p2*alpha+(1-p2)*(1-beta))
  P[4,5]=0
  P[4,6]=0
  
  P[5,1]=0
  P[5,2]=0
  P[5,3]=0
  P[5,4]=0
  P[5,5]=(p2*(1-alpha)+(1-p2)*beta)
  P[5,6]=(p2*alpha+(1-p2)*(1-beta))
  
  P[6,1]=(1-pi)^L*(p1*(1-alpha)+(1-p1)*beta)
  P[6,2]=(1-pi)^L*(p1*alpha+(1-p1)*(1-beta))
  P[6,3]=(1-(1-pi)^L)*(p2*(1-alpha)+(1-p2)*beta)
  P[6,4]=(1-(1-pi)^L)*(p2*alpha+(1-p2)*(1-beta))
  P[6,5]=0
  P[6,6]=0
  
  A = t(P) - diag(6)
  A[6,] = rep(1,6)
  B = matrix(rep(0,6),ncol = 1)
  B[6,1] = 1
  
  y = solve(A,B)
  
  # Fim da Construcao da matriz e Vetor Estacionario
  
  # Inicio do Calculo do custo - O Calculo dependera se conprimento e = m ou L
  
  # Probabilidade de estar em s0k1 e ciclo ter comprimento m
  z1=(y[1]*P[1,1]+y[3]*P[3,1]+y[5]*P[5,1])/
    (y[1]*P[1,1]+y[2]*P[2,1]+y[3]*P[3,1]+y[4]*P[4,1]+y[5]*P[5,1]+y[6]*P[6,1])
  
  #Probabilidade de estar em s0k1 e ciclo ter comprimento L
  z2=(y[2]*P[2,1]+y[4]*P[4,1]+y[6]*P[6,1])/
    (y[1]*P[1,1]+y[2]*P[2,1]+y[3]*P[3,1]+y[4]*P[4,1]+y[5]*P[5,1]+y[6]*P[6,1])
  
  #Probabilidade de estar em s0k0 e ciclo ter comprimento m
  z3=(y[1]*P[1,2]+y[3]*P[3,2]+y[5]*P[5,2])/
    (y[1]*P[1,2]+y[2]*P[2,2]+y[3]*P[3,2]+y[4]*P[4,2]+y[5]*P[5,2]+y[6]*P[6,2])
  
  #Probabilidade de estar em s0k0 e ciclo ter comprimento L
  z4=(y[2]*P[2,2]+y[4]*P[4,2]+y[6]*P[6,2])/
    (y[1]*P[1,2]+y[2]*P[2,2]+y[3]*P[3,2]+y[4]*P[4,2]+y[5]*P[5,2]+y[6]*P[6,2])
  
  #Probabilidade de estar em s1k1 e ciclo ter comprimento m
  z5=(y[1]*P[1,3]+y[3]*P[3,3]+y[5]*P[5,3])/
    (y[1]*P[1,3]+y[2]*P[2,3]+y[3]*P[3,3]+y[4]*P[4,3]+y[5]*P[5,3]+y[6]*P[6,3])
  
  #Probabilidade de estar em s1k1 e ciclo ter comprimento L
  z6=(y[2]*P[2,3]+y[4]*P[4,3]+y[6]*P[6,3])/
    (y[1]*P[1,3]+y[2]*P[2,3]+y[3]*P[3,3]+y[4]*P[4,3]+y[5]*P[5,3]+y[6]*P[6,3])
  
  #Probabilidade de estar em s1k0 e ciclo ter comprimento m
  z7=(y[1]*P[1,4]+y[3]*P[3,4]+y[5]*P[5,4])/
    (y[1]*P[1,4]+y[2]*P[2,4]+y[3]*P[3,4]+y[4]*P[4,4]+y[5]*P[5,4]+y[6]*P[6,4])
  
  #Probabilidade de estar em s1k0 e ciclo ter comprimento L
  z8=(y[2]*P[2,4]+y[4]*P[4,4]+y[6]*P[6,4])/
    (y[1]*P[1,4]+y[2]*P[2,4]+y[3]*P[3,4]+y[4]*P[4,4]+y[5]*P[5,4]+y[6]*P[6,4])
  
  #Probabilidade de estar em s2k1 e ciclo ter comprimento m
  z9=(y[1]*P[1,5]+y[3]*P[3,5]+y[5]*P[5,5])/
    (y[1]*P[1,5]+y[2]*P[2,5]+y[3]*P[3,5]+y[4]*P[4,5]+y[5]*P[5,5]+y[6]*P[6,5])
  
  #Probabilidade de estar em s2k1 e ciclo ter comprimento L
  z10=(y[2]*P[2,5]+y[4]*P[4,5]+y[6]*P[6,5])/
    (y[1]*P[1,5]+y[2]*P[2,5]+y[3]*P[3,5]+y[4]*P[4,5]+y[5]*P[5,5]+y[6]*P[6,5])
  
  #Probabilidade de estar em s2k0 e ciclo ter comprimento m
  z11=(y[1]*P[1,6]+y[3]*P[3,6]+y[5]*P[5,6])/
    (y[1]*P[1,6]+y[2]*P[2,6]+y[3]*P[3,6]+y[4]*P[4,6]+y[5]*P[5,6]+y[6]*P[6,6])
  
  #Probabilidade de estar em s2k0 e ciclo ter comprimento L
  z12=(y[2]*P[2,6]+y[4]*P[4,6]+y[6]*P[6,6])/
    (y[1]*P[1,6]+y[2]*P[2,6]+y[3]*P[3,6]+y[4]*P[4,6]+y[5]*P[5,6]+y[6]*P[6,6])
  
  #cálculo dos Custos
  custo = rep(NA,6)
  
  custo[1]=z1*(c_nc*(m-1)*(1-p1)+c_i+c_s)+z2*(c_nc*(L-1)*(1-p1)+c_i+c_s)#s0k1
  
  custo[2]=z3*(c_nc*(m-1)*(1-p1)+c_i+c_a+c_s)+z4*(c_nc*(L-1)*(1-p1)+c_i+c_a+c_s)#s0k0
  
  # Calculo s1 e s2
  ## s1
  i <- 1:m
  
  k <- (pi*(1-pi)^(i-1))/(1-(1-pi)^m)
  k <- k*((i-1)*(1-p1)+(m-i)*(1-p2))
  s1 <- sum(k)
  
  # s2
  i <- 1:L
  
  k <- (pi*(1-pi)^(i-1))/(1-(1-pi)^L)
  k <- k*((i-1)*(1-p1)+(L-i)*(1-p2))
  s2 <- sum(k)
  
  custo[3]=z5*(s1*c_nc+c_i+c_s)+z6*(s2*c_nc+c_i+c_s) #s1k1
  custo[4]=z7*(s1*c_nc+c_i+c_s+c_a)+z8*(s2*c_nc+c_i+c_s+c_a) #s1k0
  custo[5]=z9*(c_nc*(m-1)*(1-p2)+c_i+c_s)+z10*(c_nc*(L-1)*(1-p2)+c_i+c_s) #s2k1
  custo[6]=z11*(c_nc*(m-1)*(1-p2)+c_i+c_s+c_a)+z12*(c_nc*(L-1)*(1-p2)+c_i+c_s+c_a) #s2k0
  
  qtde_naoC <- c((z1*(m-1)*(1-p1) + z2*(L-1)*(1-p1)), #s0w1
    (z3*(m-1)*(1-p1) + z4*(L-1)*(1-p1)), #s0w0
    (z5*s1 + z6*s2), #s1w1
    (z7*s1 + z8*s2), #s1w0
    (z9*(m-1)*(1-p2) + z10*(L-1)*(1-p2)), #s2w1
    (z11*(m-1)*(1-p2) + z12*(L-1)*(1-p2))) #s2w2
    
  
  #Fim do Cálculo dos Custos
  
  #Cálculo do Comprimento
  T_v = rep(NA, 6)
  
  T_v[1] = z1*(m-1)+z2*(L-1)
  T_v[2] = z3*(m-1)+z4*(L-1)
  T_v[3] = z5*(m-1)+z6*(L-1)
  T_v[4] = z7*(m-1)+z8*(L-1)
  T_v[5] = z9*(m-1)+z10*(L-1)
  T_v[6] = z11*(m-1)+z12*(L-1)
  
  #Fim do cálculo do Comprimento
  
  #Cálculo do Custo Médio Total
  CP <- sum( y * custo )
  
  #Cálculo do Comprimento Médio Total
  TM <- sum( y * T_v)
  
  #Cálculo do custo Médio por Unidade Produzida e Enviada ao "Mercado"  
  CM=CP/TM
  
  # Proporção de peças não conformes enviadas ao mercado por unidade produzida
  ## Quantidade total de peças não conformes enviados ao mercado
  QT_NC <- sum(qtde_naoC * y)
  
  ## Proporção de peças não conformes enviados ao mercado por unidade produzida
  Prop_NC <- QT_NC/TM
  
  # Corrigindo erro de Nan
  if (anyNA(c(CM, Prop_NC)) | CM > penalidade_CM){
    CM <- 99
    Prop_NC <- 99
  }
  
  # retorno dos valores
  if (obj_propnc){ #Phi verdadeiro
    if (obj_cm){return(c(CM, Prop_NC))} #Phi e custo verdadeiros
    
    return(Prop_NC) # somente Phi
  }
  
  return(CM) # somente custo
}

#### func.mLr ####
func.mLr = function(vet, # Vetor de entrada Binário
                    obj_cm = TRUE, # objetivo custo medio
                    obj_propnc = FALSE, # objetivo custo medio nao conforme un produzida
                    
                    # Parametros probabilisticos
                    p1 = 0.999,
                    p2 = 0.95,
                    pi = 0.0001,
                    alpha = 0.01,
                    
                    # Parametros de Custo
                    c_i = 0.25,
                    c_nc = 20,
                    c_a = 100,
                    c_s = 2,
                    penalidade_CM = 5) # objetivo custo medio nao conforme un produzida
{
  #Modelo mL com medidas repetidas, COM loop p/ a Entrada dos Parametros modelo 2.7
  
  # Definicao dos Parametros
  
  ## Parametros Probabilísticos do Processo
  #p1 = Fracao de conformes processo sobre controle
  #p2 = Fracao de Conformes processo fora de controle
  #pi = Probabilidade de ocorrencia de shift
  #alpha = Probabilidade de classificacao nao cfe em item cfe
  #beta = Probabilidade de classificacao cfe em item nao cfe
  
  ## Parametros de custo
  #c_i = Custo de inspecao
  #c_nc = Custo envio de nao conformidade
  #c_a = Custo de ajuste
  #c_s = Custo de descarte de peca inspecionada
  
  #Fim da entrada dos Parametros
  
  # Decodificação
  m  <- binary2decimal(vet[1:8])
  L  <- binary2decimal(vet[9:18])
  r  <- binary2decimal(vet[19:23])
  a  <- binary2decimal(vet[24:length(vet)])
  
  beta <- alpha
  
  alpha = pbinom(a-1,r,1-alpha)
  beta = 1 - pbinom(a-1,r,beta)
  
  #Construcao da Matriz de Transicao e Calculo do vetor estacionário
  
  P = matrix(rep(0,36), nrow = 6)
  
  P[1,1]=(1-pi)^m*(p1*(1-alpha)+(1-p1)*beta)
  P[1,2]=(1-pi)^m*(p1*alpha+(1-p1)*(1-beta))
  P[1,3]=(1-(1-pi)^m)*(p2*(1-alpha)+(1-p2)*beta)
  P[1,4]=(1-(1-pi)^m)*(p2*alpha+(1-p2)*(1-beta))
  P[1,5]=0
  P[1,6]=0
  
  P[2,1]=(1-pi)^L*(p1*(1-alpha)+(1-p1)*beta)
  P[2,2]=(1-pi)^L*(p1*alpha+(1-p1)*(1-beta))
  P[2,3]=(1-(1-pi)^L)*(p2*(1-alpha)+(1-p2)*beta)
  P[2,4]=(1-(1-pi)^L)*(p2*alpha+(1-p2)*(1-beta))
  P[2,5]=0
  P[2,6]=0
  
  P[3,1]=0
  P[3,2]=0
  P[3,3]=0
  P[3,4]=0
  P[3,5]=(p2*(1-alpha)+(1-p2)*beta)
  P[3,6]=(p2*alpha+(1-p2)*(1-beta))
  
  P[4,1]=(1-pi)^L*(p1*(1-alpha)+(1-p1)*beta)
  P[4,2]=(1-pi)^L*(p1*alpha+(1-p1)*(1-beta))
  P[4,3]=(1-(1-pi)^L)*(p2*(1-alpha)+(1-p2)*beta)
  P[4,4]=(1-(1-pi)^L)*(p2*alpha+(1-p2)*(1-beta))
  P[4,5]=0
  P[4,6]=0
  
  P[5,1]=0
  P[5,2]=0
  P[5,3]=0
  P[5,4]=0
  P[5,5]=(p2*(1-alpha)+(1-p2)*beta)
  P[5,6]=(p2*alpha+(1-p2)*(1-beta))
  
  P[6,1]=(1-pi)^L*(p1*(1-alpha)+(1-p1)*beta)
  P[6,2]=(1-pi)^L*(p1*alpha+(1-p1)*(1-beta))
  P[6,3]=(1-(1-pi)^L)*(p2*(1-alpha)+(1-p2)*beta)
  P[6,4]=(1-(1-pi)^L)*(p2*alpha+(1-p2)*(1-beta))
  P[6,5]=0
  P[6,6]=0
  
  
  A = t(P) - diag(6)
  A[6,] = rep(1,6)
  B = matrix(rep(0,6),ncol = 1)
  B[6,1] = 1
  
  y = solve(A,B)
  
  #Fim da contrucao da Matriz e vetor estacionário
  
  #Inicio do calculo do Custo - O Calculo dependerá se o comprimento é = m ou L
  
  #Probabilidade de estar em s0k1 e ciclo ter comprimento m
  z1=(y[1]*P[1,1]+y[3]*P[3,1]+y[5]*P[5,1])/
    (y[1]*P[1,1]+y[2]*P[2,1]+y[3]*P[3,1]+y[4]*P[4,1]+y[5]*P[5,1]+y[6]*P[6,1])
  
  #Probabilidade de estar em s0k1 e ciclo ter comprimento L
  z2=(y[2]*P[2,1]+y[4]*P[4,1]+y[6]*P[6,1])/
    (y[1]*P[1,1]+y[2]*P[2,1]+y[3]*P[3,1]+y[4]*P[4,1]+y[5]*P[5,1]+y[6]*P[6,1])
  
  #Probabilidade de estar em s0k0 e ciclo ter comprimento m
  z3=(y[1]*P[1,2]+y[3]*P[3,2]+y[5]*P[5,2])/
    (y[1]*P[1,2]+y[2]*P[2,2]+y[3]*P[3,2]+y[4]*P[4,2]+y[5]*P[5,2]+y[6]*P[6,2])
  
  #Probabilidade de estar em s0k0 e ciclo ter comprimento L
  z4=(y[2]*P[2,2]+y[4]*P[4,2]+y[6]*P[6,2])/
    (y[1]*P[1,2]+y[2]*P[2,2]+y[3]*P[3,2]+y[4]*P[4,2]+y[5]*P[5,2]+y[6]*P[6,2])
  
  #Probabilidade de estar em s1k1 e ciclo ter comprimento m
  z5=(y[1]*P[1,3]+y[3]*P[3,3]+y[5]*P[5,3])/
    (y[1]*P[1,3]+y[2]*P[2,3]+y[3]*P[3,3]+y[4]*P[4,3]+y[5]*P[5,3]+y[6]*P[6,3])
  
  #Probabilidade de estar em s1k1 e ciclo ter comprimento L
  z6=(y[2]*P[2,3]+y[4]*P[4,3]+y[6]*P[6,3])/
    (y[1]*P[1,3]+y[2]*P[2,3]+y[3]*P[3,3]+y[4]*P[4,3]+y[5]*P[5,3]+y[6]*P[6,3])
  
  
  #Probabilidade de estar em s1k0 e ciclo ter comprimento m
  z7=(y[1]*P[1,4]+y[3]*P[3,4]+y[5]*P[5,4])/
    (y[1]*P[1,4]+y[2]*P[2,4]+y[3]*P[3,4]+y[4]*P[4,4]+y[5]*P[5,4]+y[6]*P[6,4])
  
  #Probabilidade de estar em s1k0 e ciclo ter comprimento L
  z8=(y[2]*P[2,4]+y[4]*P[4,4]+y[6]*P[6,4])/
    (y[1]*P[1,4]+y[2]*P[2,4]+y[3]*P[3,4]+y[4]*P[4,4]+y[5]*P[5,4]+y[6]*P[6,4])
  
  
  #Probabilidade de estar em s2k1 e ciclo ter comprimento m
  z9=(y[1]*P[1,5]+y[3]*P[3,5]+y[5]*P[5,5])/
    (y[1]*P[1,5]+y[2]*P[2,5]+y[3]*P[3,5]+y[4]*P[4,5]+y[5]*P[5,5]+y[6]*P[6,5])
  
  #Probabilidade de estar em s2k1 e ciclo ter comprimento L
  z10=(y[2]*P[2,5]+y[4]*P[4,5]+y[6]*P[6,5])/
    (y[1]*P[1,5]+y[2]*P[2,5]+y[3]*P[3,5]+y[4]*P[4,5]+y[5]*P[5,5]+y[6]*P[6,5])
  
  
  #Probabilidade de estar em s2k0 e ciclo ter comprimento m
  z11=(y[1]*P[1,6]+y[3]*P[3,6]+y[5]*P[5,6])/
    (y[1]*P[1,6]+y[2]*P[2,6]+y[3]*P[3,6]+y[4]*P[4,6]+y[5]*P[5,6]+y[6]*P[6,6])
  
  #Probabilidade de estar em s2k0 e ciclo ter comprimento L
  z12=(y[2]*P[2,6]+y[4]*P[4,6]+y[6]*P[6,6])/
    (y[1]*P[1,6]+y[2]*P[2,6]+y[3]*P[3,6]+y[4]*P[4,6]+y[5]*P[5,6]+y[6]*P[6,6])
  
  #print(c(z1,z2,z3,z4,z5,z6,z7,z8,z9,z10,z11,z12))
  
  #cálculo dos Custos
  custo = rep(NA,6)
  
  custo[1]=z1*(c_nc*(m-1)*(1-p1)+r*c_i+c_s)+z2*(c_nc*(L-1)*(1-p1)+r*c_i+c_s)#s0k1
  
  custo[2]=z3*(c_nc*(m-1)*(1-p1)+r*c_i+c_a+c_s)+z4*(c_nc*(L-1)*(1-p1)+r*c_i+c_a+c_s)#s0k0
  
  s1=0
  
  for(i in 1:m)
  {
    k=(pi*(1-pi)^(i-1))/(1-(1-pi)^m)
    k=k*((i-1)*(1-p1)+(m-i)*(1-p2))
    s1=s1+k
  }
  
  s2 = 0
  
  for(i in 1:L)
  {
    k=(pi*(1-pi)^(i-1))/(1-(1-pi)^L)
    k=k*((i-1)*(1-p1)+(L-i)*(1-p2))
    s2=s2+k
  }
  
  custo[3]=z5*(s1*c_nc+r*c_i+c_s)+z6*(s2*c_nc+r*c_i+c_s) #s1k1
  custo[4]=z7*(s1*c_nc+r*c_i+c_s+c_a)+z8*(s2*c_nc+r*c_i+c_s+c_a) #s1k0
  custo[5]=z9*(c_nc*(m-1)*(1-p2)+r*c_i+c_s)+z10*(c_nc*(L-1)*(1-p2)+r*c_i+c_s) #s2k1
  custo[6]=z11*(c_nc*(m-1)*(1-p2)+r*c_i+c_s+c_a)+z12*(c_nc*(L-1)*(1-p2)+r*c_i+c_s+c_a) #s2k0
  
  qtde_naoC <- c((z1*(m-1)*(1-p1) + z2*(L-1)*(1-p1)), #s0w1
                  (z3*(m-1)*(1-p1) + z4*(L-1)*(1-p1)), #s0w0
                  (z5*s1 + z6*s2), #s1w1
                  (z7*s1 + z8*s2), #s1w0
                  (z9*(m-1)*(1-p2) + z10*(L-1)*(1-p2)), #s2w1
                  (z11*(m-1)*(1-p2) + z12*(L-1)*(1-p2))) #s2w2
  
  #Fim do Cálculo dos Custos
  
  #Cálculo do Comprimento
  T_v = rep(NA, 6)
  
  T_v[1] = z1*(m-1)+z2*(L-1)
  T_v[2] = z3*(m-1)+z4*(L-1)
  T_v[3] = z5*(m-1)+z6*(L-1)
  T_v[4] = z7*(m-1)+z8*(L-1)
  T_v[5] = z9*(m-1)+z10*(L-1)
  T_v[6] = z11*(m-1)+z12*(L-1)
  
  #Fim do cálculo do Comprimento
  
  #Cálculo do Custo Médio Total
  CP <- sum(y * custo)
  
  #Cálculo do Comprimento Médio Total
  TM <- sum(y * T_v)
  
  #Cálculo do custo Médio por Unidade Produzida e Enviada ao "Mercado"  
  CM <- CP/TM
  
  # Proporção peças não conformes enviadas ao mercado por unidade produzida
  ## Quantidade total de não conformes enviados ao mercado
  QT_NC <- sum(qtde_naoC * y)
  
  ## Proporção de não conformes enviados ao mercado
  Prop_NC <- QT_NC/TM
  
  # Corrigindo erro de Nan
  if (anyNA(c(CM, Prop_NC)) | CM > penalidade_CM){
    CM <- 9999
    Prop_NC <- 9999
  }
  
  # retorno dos valores
  if (obj_propnc){ #Phi verdadeiro
    if (obj_cm){return(c(CM, Prop_NC))} #Phi e custo verdadeiros
    
    return(Prop_NC) # somente Phi
  }
  
  return(CM) # somente custo
}

#### func.fin ####
func.fin = function(m,tau)
{
  
  if(require(expm)==FALSE)	#é necessário instalar o pacote expm
  {
    install.packages('expm')
    require(expm)
  } 
  
  #Parametros probabilisticos do processo
  
  p1 = 0.999          # Fracao de conformes processo sob controle
  p2 = 0.95           # Fracao de conformes processo fora de controle
  pe = 0.0001         # Probabilidade de ocorrencia de 'shift' no processo
  alfa = 0.01         # Probabilidade de classificaçao nao-conforme de item cfe
  beta = 0.01         # Probabilidade de classificaçao conforme de item nao-cfe
  
  # Parametros de custo
  
  c_i = 0.25          # Custo inspecao
  c_nc = 20           # Custo envio de nao-conformidade
  c_a = 100           # Custo ajuste
  c_d = 2             # Custo peça descartada
  
  
  #tau = 2300         # Lote a ser fabricado e enviado ao mercado
  #m = 289
  N = floor(tau/(m-1))
  residuo = tau+N-N*m
  
  q = 1 - pe                         # probabilidade de não acontecer mudança
  pA = (p1*(1-alfa)+(1-p1)*beta)     # Prob inspecao cfe, dado producao sob controle
  pD = (p2*(1-alfa)+(1-p2)*beta)     # Prob inspecao cfe, dado producao fora controle
  p1_m = q^m                         # Não ocorrer shift durante fase inicial
  p2_m = 1 - p1_m                    # Ocorrer shift durante fase inicial
  
  # Shift no t-esimo item produzido fase inicial
  vetor_t = (1:m)
  q_m = q^(vetor_t-1)*pe/p2_m
  
  
  # PROBABILIDADE DE TRANSICAO
  
  # P00_00 = p1_m * (1-pA)
  # P00_01 = p1_m * pA
  # P00_10 = p2_m * (1-pD)
  # P00_11 = p2_m * pD
  # P11_20 = 1 - pD
  # P11_21 = pD
  
  
  # MATRIZ DE TRANSICAO
  
  P = matrix(rep(0,36), nrow = 6)
  
  # colunas de 1 a 4
  
  P[1,1] = p1_m * (1-pA)
  P[1,2] = p1_m * pA
  P[1,3] = p2_m * (1-pD)
  P[1,4] = p2_m * pD
  P[1,5] = 0
  P[1,6] = 0
  
  P[2,1] = p1_m * (1-pA)
  P[2,2] = p1_m * pA
  P[2,3] = p2_m * (1-pD)
  P[2,4] = p2_m * pD
  P[2,5] = 0
  P[2,6] = 0
  
  P[3,1] = p1_m * (1-pA)
  P[3,2] = p1_m * pA
  P[3,3] = p2_m * (1-pD)
  P[3,4] = p2_m * pD
  P[3,5] = 0
  P[3,6] = 0
  
  P[4,1] = 0
  P[4,2] = 0
  P[4,3] = 0
  P[4,4] = 0
  P[4,5] = 1-pD
  P[4,6] = pD
  
  P[5,1] = p1_m * (1-pA)
  P[5,2] = p1_m * pA
  P[5,3] = p2_m * (1-pD)
  P[5,4] = p2_m * pD
  P[5,5] = 0
  P[5,6] = 0
  
  P[6,1] = 0
  P[6,2] = 0
  P[6,3] = 0
  P[6,4] = 0
  P[6,5] = 1-pD
  P[6,6] = pD
  
  b = c(1,0,0,0,0,0)
  
  d = matrix(rep(0,7*6), ncol = 6)
  for(i in 1:N)
  {
    c = b%*%(P%^%i)
    d[i,1] = c[1]
    d[i,2] = c[2]
    d[i,3] = c[3]
    d[i,4] = c[4]        
    d[i,5] = c[5]       
    d[i,6] = c[6]
  }
  E = rep(0,6)
  if(N==1)
  {
    E = d
  }else
  {
    for(i in 1:6)
    {
      E[i] = mean(d[,i])
    }  
  }
  
  
  #---------------------------CUSTO DOS ESTADOS-------------------------------#
  
  # Estados (0,0) e (0,1)
  
  mercado_00 = c_nc * (m - 1)*(1 - p1)
  descarte_00 = c_d
  ajuste_00 = c_a
  Phi_00 = c_i + mercado_00 + descarte_00 + ajuste_00
  
  mercado_01 = mercado_00
  descarte_01 = c_d
  ajuste_01 = 0
  Phi_01 = c_i + mercado_01 + descarte_01
  
  # Estados (1,0) e (1,1)  
  
  mercado_10 = c_nc*sum(q_m*((vetor_t-1)*(1-p1)+(m-vetor_t)*(1-p2)))
  descarte_10 = c_d
  ajuste_10 = c_a
  Phi_10 = c_i + mercado_10 + descarte_10 + ajuste_10
  
  mercado_11 = mercado_10
  descarte_11 = c_d
  ajuste_11 = 0
  Phi_11 = c_i + mercado_11 + descarte_11
  
  # Estados (2,0) e (2,1)  
  
  mercado_20 = c_nc * (m - 1)*(1 - p2)
  descarte_20 = c_d
  ajuste_20 = c_a
  Phi_20 = c_i + mercado_20 + descarte_20 + ajuste_20
  
  mercado_21 = mercado_20
  descarte_21 = c_d
  ajuste_21 = 0
  Phi_21 = c_i + mercado_21 + descarte_21
  
  
  # Vetor de Custo
  
  Phi = c(Phi_00,Phi_01,Phi_10,Phi_11,Phi_20,Phi_21)
  
  # Custo relativo ao residuo
  c # ja calculado
  
  
  # Ultima inspeção no estado 00 ou 01
  p1a = q^residuo  # Sem troca de estado no resíduo
  c1a = residuo*(1-p1)*c_nc
  p1b = 1 - p1a
  vetor = c(1:residuo)
  q_m = q^(vetor-1)*pe/p1b
  c1b = c_nc*sum(q_m*((vetor-1)*(1-p1)+(residuo-vetor+1)*(1-p2)))
  c1c = residuo*(1-p2)*c_nc
  
  parte1 = (c[1] + c[2] + c[3] + c[5])*(p1a*c1a+p1b*c1b)
  parte2 = (c[4]+c[6])*(c1c)
  cr = parte1+parte2
  
  #CM(cont)=(E%*%Phi)/(m-1);
  CM=((E%*%Phi)*N+cr)/(N*(m-1)+residuo)
  
  return(CM)
}
#### func.mLna ####
func.mLna = function(x)
{  
  library(Matrix)
  
  m = ceiling(x[1])
  L = ceiling(x[2])
  N = ceiling(x[3])
  a = ceiling(x[4])
  
  # Parametros do probabilisticos do processo
  
  p1 = 0.999       # Fracao de conformes processo sob controle
  p2 = 0.95        # Fracao de conformes processo fora controle
  pe = 0.0001      # Probabilidade ocorrencia shift processo
  alfa = 0.01      # Probabilidade classificacao nao cfe item cfe
  beta = alfa      # Probabilidade classificacao cfe item nao-cfe
  
  # Componentes de custo
  
  c_i   = 0.25     # Custo inspecao
  c_nc  = 20       # Custo envio de nao-conformidade
  c_a   = 1000     # Custo ajuste
  c_snc = 2        # Custo item nao-cfe inspecionado/descartado
  c_sc  = 2        # Custo item cfe inspecionado/descartado
  
  # Parametros da simulacao
  
  d0 = 1           # producao entre itens inspecionados
  # d = d0 >=1, para n>1, d=0 para n = 1
  
  # ---------------------------------------------------------------------------------------
  #                 Calculo de quantidades que nao dependem de m ou de L
  # ---------------------------------------------------------------------------------------
  q = 1 - pe
  
  # -------------------------------------------------------------------
  #           Probabilidades dado producao sob controle
  # -------------------------------------------------------------------
  
  # Prob inspecao cfe, dado producao sob controle
  pA = (p1*(1-alfa)+(1-p1)*beta)    
  p10 = 1 - pA
  
  # Probabilidades da situacao do item inspecionado
  
  # Nomenclatura
  
  # p(decisao dada a situacao do processo de producao
  # 1 - producao sob controle; 0 - producao fora controle
  # 1 - julgamento conforme; 0 - julgamento nao cfe;
  # c: situacao real - cfe; n: situacao real - nao cfe
  
  # Prob item cfe dado inspecao cfe e producao sob controle
  p11c = p1*(1-alfa)/pA    
  # Prob item nao cfe dado inspecao cfe e producao controle            
  p11n = 1 - p11c          
  # Prob item cfe dado inspecao nao cfe e producao controle          
  p10c = p1*alfa/(1-pA)    
  # Prob item nao cfe dado insp. nao cfe producao controle            
  p10n = 1 - p10c           
  
  # ------------------------------------------        
  # Probabilidades dado producao fora controle
  # ------------------------------------------
  
  # Prob inspecao cfe, dado producao fora controle
  pD = (p2*(1-alfa)+(1-p2)*beta)
  p00 = 1 - pD
  
  # Probabilidades da situacao do item inspecionado
  
  # Prob item cfe dado insp. cfe e producao fora controle
  p21c = (p2*(1-alfa))/pD
  # Prob item nao cfe dado insp. cfe e prod. fora controle
  p21n = 1 - p21c
  # Prob item cfe dado insp. nao cfe e prod. fora controle        
  p20c = (p2*alfa)/(1-pD)
  # Prob item nao cfe dado insp. nao cfe e prod. fora cont.            
  p20n = 1 - p20c
  
  
  # -------------------------------------------------------        
  #       Probabilidades entre itens inspecionados
  # -------------------------------------------------------
  
  # Variaveis do modelo computacional
  
  # Custos Mercado Parcial - Nao depende de L, N ou a
  
  # ---- Ciclo comprimento m -----
  
  vet_m = c(1:m)
  
  # probabilidade de shift instante t dado shift
  
  q_m = q^(vet_m - 1)*pe/(1 - q^m)        
  vet_soma_qm = q_m*((vet_m - 1)*(1-p1)+(m - vet_m + 1)*(1-p2))
  
  # Esperanca dos itens enviados ao mercado, dado shift
  
  soma_qm = sum(vet_soma_qm)             
  
  # Custos Mercado Parcial - Nao depende de N ou a
  
  # ---- Ciclo comprimento L -----
  
  vet_L=(1:L)
  
  # probabilidade de de shift instante t dado shift
  
  q_L = q^(vet_L - 1)*pe/(1 - q^L)     
  
  vet_soma_qL = q_L*((vet_L - 1)*(1-p1)+(L - vet_L + 1)*(1-p2))
  
  # Esperanca dos itens enviados ao mercado, dado shift
  
  soma_qL = sum(vet_soma_qL);             
  
  # Transformar d = 0 (n=1) e d = d (n>1).
  
  compatibilizador = ceiling((N-1)/N)      # 0 para n=1 
  # 1 para n>1.
  d = d0 * compatibilizador                # d=0, se n=1
  # d=d, se n>1
  
  # --- Quantidade de itens produzidos amostragem
  
  erre = (N-1)*d+1
  
  # Qte nao cfe mercado - shift durante amostragem
  
  soma_k = 0
  nu_2s = 0
  
  if(N>1)
  {
    vetor_r = c(1 : erre)                   
    # Probabilidade shift item r                                        
    q_R = q^(vetor_r-1)*pe/(1-q^erre)
    # Qte inspecoes sob controle 
    vetor_k = ceiling((vetor_r-1)/d)
    # Qte enviada mercado sob controle 
    qte_in  = (vetor_r-(vetor_k+1))
    # Qte enviada mercado fora controle
    qte_out = (erre - N) - qte_in
    termo_k =q_R*(qte_in * (1-p1) + qte_out*(1-p2))
    nu_2s = sum(termo_k)
  } #if
  
  # ----- Probabilidades NAO Ajustar Processo
  
  vetor_0 = c(0:(a-1))
  vetor_a = c(a:N)
  
  vetor_Ba_pA = dbinom(vetor_a,N,pA)
  vetor_Ba_pD = dbinom(vetor_a,N,pD)
  
  vetor_B0_pA = dbinom(vetor_0,N,pA)
  vetor_B0_pD = dbinom(vetor_0,N,pD)
  
  # toda a amostra coletada sob controle  
  Ba_pA = sum(vetor_Ba_pA)
  # toda a amostra coletada fora controle  
  Ba_pD = sum(vetor_Ba_pD) 
  
  # ------Transicao apos ajuste 
  
  Pw0_00 = q^(L + erre)*(1-Ba_pA)
  Pw0_01 = q^(L + erre)*(Ba_pA)
  Pw0_10 = (1 - q^L)*(1-Ba_pD)
  Pw0_11 = (1 - q^L)*(Ba_pD)
  
  # ----- Transicao sob controle sem ajuste  
  
  P01_00 = q^(m + erre)*(1-Ba_pA)
  P01_01 = q^(m + erre)*(Ba_pA)
  P01_10 = (1 - q^m)*(1-Ba_pD)
  P01_11 = (1 - q^m)*(Ba_pD)
  
  # ----- Transicao fora de controle 
  
  Pw1_30 = 1 - Ba_pD
  Pw1_31 = Ba_pD
  
  # ---- Transicao shift amostragem  
  
  flag = min(1,N-1)
  prob_resto_21 = 0
  prob_resto_20 = 0
  cfe_resto_21 = 0
  cfe_resto_20 = 0
  
  while(flag == 1)
  {
    soma_prob_k_21 = 0
    soma_cfe_k_21  = 0
    soma_ncfe_k_21 = 0
    
    soma_prob_k_20 = 0
    soma_cfe_k_20  = 0
    soma_ncfe_k_20 = 0
    
    for(k in 1:N-1)
    {
      soma_prob_u_21 = 0
      soma_cfe_u_21  = 0
      soma_ncfe_u_21 = 0
      
      soma_prob_u_20 = 0
      soma_cfe_u_20  = 0
      soma_ncfe_u_20 = 0
      
      for(u in 0:k)
      {
        # ---- Estado (2,1) -----
        
        vet_prob_j_21 = dbinom(vetor_a - u, N-k,pD)
        soma_prob_j_21 = sum(vet_prob_j_21)
        
        vet_cfe_j_21 = (p11c*u + p10c*(k -u)+p21c*(vetor_a- u)+p20c*(N-k-vetor_a+u))*dbinom(vetor_a-u,N-k,pD)
        soma_cfe_j_21 = sum(vet_cfe_j_21)
        
        # ---- Estado (2,0) -----
        
        vet_prob_j_20 = dbinom(vetor_0 - u, N-k,pD)
        soma_prob_j_20 = sum(vet_prob_j_20)
        
        vet_cfe_j_20 = (p11c*u + p10c*(k -u) + p21c*(vetor_0 - u) + p20c*(N - k - vetor_0 +u))*dbinom(vetor_0-u,N-k,pD)
        soma_cfe_j_20 = sum(vet_cfe_j_20)
        
        prob_u = dbinom(u,k,pA)
        
        # ---- Estado (2,1) -----
        
        prob_u_j_21 = prob_u * soma_prob_j_21
        soma_prob_u_21 = soma_prob_u_21+prob_u_j_21
        
        cfe_u_j_21 = soma_cfe_j_21*prob_u
        soma_cfe_u_21 = soma_cfe_u_21+cfe_u_j_21
        
        # ---- Estado (2,0) -----
        
        prob_u_j_20= prob_u * soma_prob_j_20
        soma_prob_u_20 = soma_prob_u_20+prob_u_j_20
        
        cfe_u_j_20 = soma_cfe_j_20*prob_u
        soma_cfe_u_20 = soma_cfe_u_20+cfe_u_j_20
        
      }#for u
      
      prob_k = q^((k-1)*d)
      
      # ---- Estado (2,1) -----
      
      prob_k_u_21 = prob_k*soma_prob_u_21
      soma_prob_k_21 = soma_prob_k_21 + prob_k_u_21
      
      cfe_k_u_21 = prob_k*soma_cfe_u_21
      soma_cfe_k_21 = soma_cfe_k_21 + cfe_k_u_21
      
      # ---- Estado (2,0) -----
      
      prob_k_u_20 = prob_k*soma_prob_u_20
      soma_prob_k_20= soma_prob_k_20+prob_k_u_20
      
      cfe_k_u_20 = prob_k*soma_cfe_u_20
      soma_cfe_k_20 = soma_cfe_k_20 + cfe_k_u_20
      
    }# for k
    
    flag=0
    prob_resto_21 = (q*(1 - q^d))*soma_prob_k_21
    prob_resto_20 = (q*(1 - q^d))*soma_prob_k_20
    cfe_resto_21 = (q*(1-q^d))*soma_cfe_k_21
    cfe_resto_20 = (q*(1-q^d))*soma_cfe_k_20
  }#while flag
  
  # Probabilidades Estados (2,0) e (2,1)
  
  prob_1a_21 =  pe * Ba_pD
  
  
  Pw0_21 = q^L*(prob_1a_21+prob_resto_21)
  P01_21 = q^m*(prob_1a_21+prob_resto_21)
  
  prob_1a_20 =  pe *(1- Ba_pD)
  
  Pw0_20 = q^L*(prob_1a_20+prob_resto_20)
  P01_20 = q^m*(prob_1a_20+prob_resto_20)
  
  # Qte. Esperada Realmente Conformes/Nao-cfes
  
  # ---- Estado (2,1) -----
  
  cfe_1a_21 = sum((p21c*vetor_a +p20c*(N-vetor_a))*dbinom(vetor_a,N,pD))*pe
  
  cfe_21 = ((1-pe)^L/Pw0_21)*(cfe_1a_21+ cfe_resto_21)
  ncfe_21 = N - cfe_21
  
  # ---- Estado (2,0) -----
  
  cfe_1a_20 = sum((p21c*vetor_0+p20c*(N - vetor_0))*dbinom(vetor_0,N,pD))*pe
  cfe_20 = ((1-pe)^L/Pw0_20)*(cfe_1a_20 + cfe_resto_20)
  ncfe_20 = N - cfe_20
  
  
  # ------------------------------------------------------
  #                 Matriz de Transicao 
  # ------------------------------------------------------
  
  P = Matrix(0,8,8, sparse = T)
  
  
  vetor  = c(Pw0_00, Pw0_01, Pw0_10, Pw0_11, Pw0_20, Pw0_21)
  linhas = c(1, 3, 5, 7)
  colunas= c(1:6)
  tamanho = length(linhas)                  # qte de linhas
  parcial_16 = matrix(rep(vetor, tamanho), ncol = length(vetor), byrow = T)                    
  P[linhas, colunas] = parcial_16
  
  # linha (0,1)
  
  P[2,1:6] = c(P01_00, P01_01, P01_10,P01_11,P01_20,P01_21)
  
  # linhas (1,1), (2,1), (3,1)
  
  vetor  = c(Pw1_30, Pw1_31)
  linhas = c(4, 6, 8)
  colunas= c(7, 8)
  tamanho = length(linhas)              # qte de linhas
  parcial_78 = matrix(rep(vetor,tamanho), ncol = length(vetor), byrow = T)
  P[linhas, colunas] = parcial_78
  
  P = matrix(P, nrow = 8)
  
  # ---------------------------------------------------------------
  #                     Distribuicao Invariante 
  # ---------------------------------------------------------------
  
  A = t(P) - diag(8)
  A[8,] = rep(1, 8)
  B = matrix(0,8,1)
  B[8,1] = 1
  invariante = solve(A,B)
  
  # -------------------------------------------------------------
  #    Probabilidades de Comprimento de Ciclo
  # -------------------------------------------------------------
  
  soma_pi0 = c(1,0, 1, 0, 1, 0, 1, 0)%*%invariante
  
  # Soma probabilidades estados s=0  
  P_L = P[1,]*soma_pi0/(t(invariante)+.Machine$double.eps) 
  
  pL_00 = P_L[1]
  pL_01 = P_L[2]
  pL_10 = P_L[3]
  pL_11 = P_L[4]
  pL_20 = P_L[5]
  pL_21 = P_L[6]
  
  # --------------------------------------------
  #               Custos dos Estados
  # --------------------------------------------
  
  # Estado (0,0)
  
  # ----- Mercado -------
  
  mercado_00  = c_nc*((1-pL_00)*m + pL_00*L + erre - N)*(1-p1)
  
  # ---- Descarte -------
  
  vetor=vetor_0
  vet_scrap_00c =(vetor * p1*(1-alfa)/pA + (N-vetor)*p1*alfa/(1-pA))* vetor_B0_pA
  cfe_00 = sum(vet_scrap_00c)/sum(vetor_B0_pA)
  ncfe_00 = N - cfe_00
  
  descarte_00 = cfe_00*c_sc+ncfe_00*c_snc
  
  # ---- Custo Estado (0,0)
  
  ajuste_00 = c_a
  custo_00 = N*c_i + mercado_00 + descarte_00 + ajuste_00
  
  # Estado (0,1)
  
  # ----- Mercado -------
  
  mercado_01  = c_nc*((1-pL_01)*m + pL_01*L + erre - N)*(1-p1)
  
  # ---- Descarte -------
  
  vetor=vetor_a
  vet_scrap_01c = (vetor*p1*(1-alfa)/pA + (N-vetor)*p1*alfa/(1-pA))* vetor_Ba_pA
  cfe_01 = sum(vet_scrap_01c)/Ba_pA
  ncfe_01 = N - cfe_01
  
  descarte_01=cfe_01*c_sc+ncfe_01*c_snc
  
  # ---- Custo Estado (0,1)
  
  ajuste_01 = 0
  custo_01 = N*c_i + mercado_01 + descarte_01 + ajuste_01
  
  # Estado (1,0)
  
  # ----- Mercado -------
  
  mercado_10=c_nc*(soma_qm*(1-pL_10) + soma_qL*pL_10+(erre-N)*(1-p2))
  
  # ---- Descarte -------
  
  vetor = vetor_0
  vet_scrap_10c = (vetor*p2*(1-alfa)/pD + (N-vetor)*p2*alfa/(1-pD))* vetor_B0_pD
  cfe_10 = sum(vet_scrap_10c)/sum(vetor_B0_pD)
  ncfe_10 = N - cfe_10
  
  descarte_10=cfe_10*c_sc+ncfe_10*c_snc
  
  # ---- Custo Estado (1,0) --------
  
  ajuste_10 = c_a
  custo_10 = N*c_i + mercado_10 + descarte_10 +ajuste_10
  
  # Estado (1,1)
  
  # ----- Mercado -------
  
  mercado_11 = c_nc*(soma_qm*(1-pL_11)+soma_qL*pL_11+(erre - N)*(1-p2))
  
  # ---- Descarte -------
  
  vetor = vetor_a
  vet_scrap_11c = (vetor*p2*(1-alfa)/pD + (N-vetor)*p2*alfa/(1-pD))* vetor_Ba_pD
  cfe_11 = sum(vet_scrap_11c)/Ba_pD
  ncfe_11 = N - cfe_11
  
  descarte_11 = cfe_11*c_sc+ncfe_11*c_snc
  
  # ---- Custo Estado (1,1)
  
  ajuste_11 = 0
  custo_11 = N*c_i + mercado_11 + descarte_11 +ajuste_11
  
  
  # Estado (2,0)
  
  mercado_20 = c_nc*((m*(1-pL_20)+ L*pL_20)*(1-p1) + nu_2s)
  descarte_20=cfe_20*c_sc+ncfe_20*c_snc
  ajuste_20 = c_a
  
  custo_20 = N*c_i + mercado_20 + descarte_20 +ajuste_20
  
  # Estado (2,1)
  
  mercado_21  = c_nc*((m*(1-pL_21) + L*pL_21)*(1-p1) + nu_2s)
  descarte_21=cfe_21*c_sc+ncfe_21*c_snc
  ajuste_21   = 0
  
  custo_21 = N*c_i + mercado_21 + descarte_21 +ajuste_21
  
  # Estado (3,0)
  
  # ----- Mercado -------
  
  mercado_30 = c_nc*(m + erre - N)*(1-p2)
  
  # ---- Custo Estado (3,0) --------
  
  descarte_30= descarte_10
  ajuste_30 = c_a
  custo_30 = N*c_i + mercado_30 + descarte_30 +ajuste_30
  
  # Estado (3,1)
  
  # ----- Mercado -------
  
  mercado_31  = mercado_30
  
  # ---- Custo Estado (3,1) ------ 
  
  descarte_31= descarte_11
  ajuste_31 = 0
  custo_31 = N*c_i + mercado_31 + descarte_31 +ajuste_31
  
  # ------  Vetor de Custos  -------
  
  Custo = c(custo_00,custo_01,custo_10,custo_11,custo_20,custo_21,custo_30,custo_31)
  # -------------------------------------------------------------------
  #              Calculo Custo Medio por Unidade 
  # --------------------------------------------------------------------
  
  # Qte media itens produzidos entre ajustes 
  ItemMedio = m + (erre-N) + (L-m)*soma_pi0
  # soma_pi0:prob.estados s=0
  
  # Custo medio entre ajustes sucessivos
  CustoMedio = Custo%*%invariante  
  
  # Custo medio por unidade  
  CM = CustoMedio/ItemMedio
  
  return(CM)
}
