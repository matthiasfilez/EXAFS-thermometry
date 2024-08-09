function [T_profile,slope,offset] = EXAFS_thermometry(FT_EXAFS,R,time,FT_EXAFS_calibration,temperature)

% code generated by Matthias Filez (matthias.filez@ugent.be) in 2024
% (please cite paper when using this script)
%
% Input arguments of the function:
%   1. FT_EXAFS: m x n matrix with a series of R-space FT EXAFS
%      profiles (their magnitude), where m is the number of FT EXAFS 
%      profiles and n is the length of R (radial distance axis in Angstrom).
%   2. R: vector of length n containing the R-space values of FT_EXAFS 
%      (radial distance axis in Angstrom).
%   3. time: vector of length m containing the timestamps (in seconds) of 
%      the series of FT_EXAFS matrix, starting at time 0 s.
%   4. FT_EXAFS_calibration: p x n matrix with a series of R-space FT EXAFS
%      profiles (their magnitude), where p is the number of FT EXAFS profiles
%      and n is the length of R (see '2.').
%   5. temperature: vector of length p containing the corresponding
%      temperatures (in °C) at which the individual FT EXAFS profiles in
%      FT_EXAFS_calibration are measured.
%
% Output:
%   1. T_profile: vector of length m containing the temperature of the
%      phase of interest.
%   2. slope: integer consisting of the slope of the linear relationship
%      between ln(|X(R)|_max) and the temperature.
%   3. offset: integer consisting of the offset of the linear relationship
%      between ln(|X(R)|_max) and the temperature. 
%   The parameters slope and offset allow to fully reconstruct the
%   EXAFS-temperature relationship.
%
% Note: the units on the |X(R)| axis labels are now implemented for
% k^2-weighted EXAFS spectra. This is purely a printing property and hence
% does not affect the calculations

%% initialize

m = length(FT_EXAFS(:,1));
n = length(FT_EXAFS(1,:));
p = length(FT_EXAFS_calibration(:,1));

%% plot FT EXAFS data for EXAFS-temperature calibration

figure()
subplot(2,2,1)

hold on
for i = 1:p
plot(R,FT_EXAFS_calibration(i,:),'Color',[i/p 0 (p-i)/p]./255)
end
xlim([0 4])
box on
Ang = char(197);
xlabel(['radial distance [' Ang ']'])
ylabel(['|\chi(R)| [' Ang '^{-3}]'])

%% extract and plot linear EXAFS-temperature relationship and estimate slope and offset

ln_XR_max_cali = log(max(FT_EXAFS_calibration,[],2));
f = fit(temperature,ln_XR_max_cali,'poly1')
slope = f.p1;
offset = f.p2;

temp = [temperature(1):(temperature(end)-temperature(1))/100:temperature(end)];
ln_XR_max_reconstruct = slope.*temp + offset;

subplot(2,2,2)

hold on
plot(temp,ln_XR_max_reconstruct,'--k')
scatter(temperature,ln_XR_max_cali,'.b')
box on
axis tight
ylabel('ln(|\chi(R)|_{max}) [-]')
xlabel('temperature [°C]')

%% plot FT EXAFS data on which thermometry needs to be applied

subplot(2,2,3)

hold on
for i = 1:m
plot(R,FT_EXAFS(i,:),'Color',[i/m 0 (m-i)/m]./255)
end
xlim([0 4])
box on
Ang = char(197);
xlabel(['radial distance [' Ang ']'])
ylabel(['|\chi(R)| [' Ang '^{-3}]'])

%% from FT EXAFS to temp

ln_XR_max = log(max(FT_EXAFS,[],2));
T_profile = (ln_XR_max - offset)./slope;

subplot(2,2,4)

plot(time./60,T_profile)
box on
axis tight
xlabel('time-on-stream [min]')
ylabel('temperature [°C]')

end