function simulate_bilayer_bulk()
    % How many positions and energies to consider
    positions = 64;
    energies  = 20;

    % Strengths of the exchange field and spin-orbit field
    h = [0 1/10 1/5 1 5 10];
    a = [0 1/10 1/5 1 5 10];


    iterations = [length(h), length(a)];
    parfor n=1:prod(iterations)
        % Retrieve the indices corresponding to this iteration and
        [i,j] = ind2sub(iterations,n);

        % Information about parallel execution
        task = getCurrentTask();
        if isempty(task)
            taskID = 0;
        else
            taskID = task.ID;
        end

        % Display progress information and make sure results can be saved
        fprintf(':: Worker %2.0f: commencing calculation for h=%2.2f, a=%2.2f\n', taskID, h(i), a(j));
        filename = sprintf('ferromagnet_h%2.2f_a%2.2f', h(i), a(j));
        parsave(filename, 'f');

        % Instantiate a ferromagnet
        f = Ferromagnet( linspace(0,1,positions), linspace(0.01, 1.3, energies) );

        % Change the exchange and spin-orbit fields of the ferromagnet
        f.exchange  = [h(i),0,0];
        f.spinorbit = SpinVector.RashbaDresselhaus(a(j),pi/4);

        % Set the boundary conditions for the ferromagnet (i.e. connect it to a bulk superconductor)
        f.interface_left = 1;
        for m=1:length(f.energies)
            f.boundary_left(m) = Superconductor.Bulk(f.energies(m), 1.0);
        end

        % Update the internal state of the ferromagnet
        f.update;

        % Store the results of the simulation 
        parsave(filename, f);

        % Display progress information
        fprintf(':: Worker %2.0f: saving results to "%s".\n', taskID, filename);
    end
end

function parsave(filename, output)
    save(sprintf('output/%s.mat', filename), 'output');
end