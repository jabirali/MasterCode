% This script calculates the superconducting gap as a function of temperature.

% Define the physical parameters
thouless     = 1/100;
strength     = 0.2;

% Define the simulation parameters
output       = 'output/critical_superconductor_linear/';
positions    = linspace(0, 1, 10);
temperatures = linspace(0, 1.2, 30);
energies     = [linspace(0,0.500,100) linspace(0.501,1.500,100), linspace(1.501,cosh(1/strength),100)];

% Create a superconductor based on the parameters above
s = Superconductor(positions, energies, thouless, strength);
s.debug = false;

% Make sure that all required classes and methods are in the current path
initialize;

% Create the output directory (if it doesn't already exist)
mkdir(output);

% Log the program output to a file
diary([output, 'log.txt']);

% Define variables used to store results
gap  = 1;                          % Current superconducting gap
gaps = zeros(size(temperatures));  % All the calculated gaps

tic;
for n=1:length(temperatures)    
    % Status information
    fprintf('\n:: PROGRAM: [ %3d / %3d ] [ Time: %2d min ] [ T = %.6f ] [ gap = %.6f ]\n',  n, length(temperatures), floor(toc/60), temperatures(n), gap);

    % Increase the superconductor temperature, and update the gap and state
    s.temperature = temperatures(n);
    s.update_gap;
    s.update;
    
    % Keep updating the internal state of the superconductor until the gap
    % converges (i.e. less than 0.1% change between iterations)
    while (abs(gap - s.mean_gap) > 1e-3) && (abs(gap) > 1e-3)
        % Status information
        fprintf('\n:: PROGRAM: [ %3d / %3d ] [ Time: %2d min ] [ T = %.6f ] [ gap = %.6f ]\n            Gap changed by %.2f%%. Recalculating...\n',  n, length(temperatures), floor(toc/60), temperatures(n), s.mean_gap, 100*abs(1-s.mean_gap/gap));
            
        % Update the superconductor state
        gap = s.mean_gap;
        s.update;
    end
    
    % Store the current result in the vector 'gaps'
    gaps(n) = s.mean_gap;
end

% Save the results to file
save([output, 'results.mat'], 'temperatures', 'gaps');

% Disable the logging
diary off;

% Plot the results
figure;
title('Plot of temperature vs. superconducting gap');
plot(temperatures, gaps);
xlabel('Temperature');
ylabel('Superconducting gap');