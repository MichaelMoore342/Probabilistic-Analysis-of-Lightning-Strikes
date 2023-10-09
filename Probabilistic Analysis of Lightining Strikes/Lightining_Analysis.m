%Load in data
LightningData = readtable('Lightning_Strokes_JHB_20km.csv','NumHeaderLines',1);
PeakCurrent_original = LightningData{:,5};
PeakCurrent = abs(PeakCurrent_original);

%Statistical properties
MeanCurrent = mean(PeakCurrent);
Variance = var(PeakCurrent);
SD = sqrt(Variance);
Range = range(PeakCurrent);
Minimum = min(PeakCurrent);
Maximum = max(PeakCurrent);

%Calculate probability distribution
P = nnz(PeakCurrent==Minimum)/length(PeakCurrent);

for i = Minimum+1:Maximum
    Pnext = nnz(PeakCurrent == i)/length(PeakCurrent);
    ProbabilityVec = [P Pnext];
    P = ProbabilityVec;
end

%Gaussian distribution
pd = fitdist(PeakCurrent,'Normal');
x = -59:0.54:75;
pdf_normal = pdf(pd,x);
cdf_normal = cdf(pd,x);

%Gamma distribution
x2 = 0:0.3213:80;
gammaInput = gamrnd(3,5,100,1);
pd2 = fitdist(gammaInput,'gamma');
pdf_gamma = gampdf(x2,2,5);
cdf_gamma = cdf(pd2,x2);

%Rayleigh distribution
pdf_ray = raylpdf(x2,8);
cdf_ray = raylcdf(x2,8);

%RMSE
RMSE_normal = sqrt(mean((ProbabilityVec -  pdf_normal).^2)) 
RMSE_gamma = sqrt(mean((ProbabilityVec -  pdf_gamma).^2)) 
RMSE_ray = sqrt(mean((ProbabilityVec -  pdf_ray).^2)) 

%SSE
Normalsum = 0;
for j = 1:length(ProbabilityVec)
    k = (ProbabilityVec(j)- pdf_normal(j)).^2;
    Normalsum = Normalsum + k;
end
Normalsum

Gammasum = 0;
for j = 1:length(ProbabilityVec)
    k = (ProbabilityVec(j)- pdf_gamma(j)).^2;
    Gammasum = Gammasum + k;
end
Gammasum

Raysum = 0;
for j = 1:length(ProbabilityVec)
    k = (ProbabilityVec(j)- pdf_ray(j)).^2;
    Raysum = Raysum + k;
end
Raysum

%TSS
NormalTSS = 0;
for j = 1:length(ProbabilityVec)
    k = (pdf_normal(j)- mean(pdf_normal)).^2;
    NormalTSS = NormalTSS + k;
end
NormalTSS

GammaTSS = 0;
for j = 1:length(ProbabilityVec)
    k = (pdf_gamma(j)- mean(pdf_gamma)).^2;
    GammaTSS = GammaTSS + k;
end
GammaTSS

RayTSS = 0;
for j = 1:length(ProbabilityVec)
    k = (pdf_ray(j)- mean(pdf_ray)).^2;
    RayTSS = RayTSS + k;
end
RayTSS

%R squared 
Rsquared_normal = 1-(Normalsum/NormalTSS)
Rsquared_gamma = 1-(Gammasum/GammaTSS)
Rsquared_ray = 1-(Raysum/RayTSS)

figure
h = histogram(PeakCurrent,'Normalization','probability');
hold on
plot(x,pdf_normal,'LineWidth',2)
hold on
plot(x2,pdf_gamma,'LineWidth',2)
hold on
plot(x2,pdf_ray,'LineWidth',2)
xlim([-40 80])
xlabel("Peak Current (kA)")
ylabel("Probability")
title("Probability Density Functions Compared to Empirical Data")
legend("Empirical data","Gaussian distribution","Gamma distribution","Rayleigh distribution")

figure
cdfplot(PeakCurrent)
hold on
plot(x,cdf_normal)
hold on
plot(x2,cdf_gamma)
hold on
plot(x2,cdf_ray)
xlim([-50 100])
xlabel("Peak Current (kA)")
ylabel("Cumulative Probability")
title("Cumulative Density Functions Compared to Cumulative Probability of Empirical Data")
legend("Empirical data","Gaussian distribution","Gamma distribution","Rayleigh distribution")
