A=87.6;% 定义 A 的值  
 


x = real(sim_beam_frac);
% u Law 计算公式，计算 yu  
% yu=sign(x).*log(1+u*abs(x))/log(1+u);
% A Law 计算公式，循环计算 ya  
for i=1:length(x)
   if abs(x(i))<1/A
      ya(i)=A*x(i)/(1+log(A));
   else
      ya(i)=sign(x(i))*(1+log(A*abs(x(i))))/(1+log(A));
   end
end

ya=ya.';
