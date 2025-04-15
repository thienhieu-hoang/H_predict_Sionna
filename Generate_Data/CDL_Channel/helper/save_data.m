function save_data(H_true, H_time, H_equalized, H_linear, H_practical, OFDM_current, idxFolder, snr, shuff_flag, flag_split)
    
    if nargin < 9
        shuff_flag = 0;  % Default value for shuff_flag
    end
    if nargin < 10
        flag_split = 0;  % Default value for flag_split
    end

    % % % Check if the save folder exists
    save_folder =  ['generatedChannel/ver', num2str(idxFolder),'_/', num2str(snr),'dB'];  
    if ~exist(save_folder, 'dir')
        mkdir(save_folder);
    end

    H_time_current = H_time(1:(15360*OFDM_current/14), :);             % 15360*n_slot_current x 1
    H_time_future  = H_time((15360*OFDM_current/14+1) :end, :);
    H_true_current = H_true(1:OFDM_current,:, :);            % 14*n_slot_current x 612
    H_true_future  = H_true((OFDM_current+1):end, :, :);

    if shuff_flag == 1
        shuff = randi([1,size(H_true,3)], size(H_true,3), 1);  % random, not permute
    
        H_true      = H_true(:,:,shuff);
        H_equalized = H_equalized(:,:,shuff);
        H_linear    = H_linear(:,:,shuff);
        H_practical = H_practical(:,:,shuff);

        H_true_current = H_true_current(:,:,shuff);
        H_time_current = H_time_current(:,shuff);
        H_time_future  = H_time_future(:,shuff);
        H_true_future  = H_true_future(:,:,shuff); 
        H_time         = H_time(:,shuff);
        H_true         = H_true(:,:,shuff);
    end

    if flag_split == 1
        H_equalized_data(:,:,1,:) = real(H_equalized);
        H_equalized_data(:,:,2,:) = imag(H_equalized);
    
        H_linear_data(:,:,1,:) = real(H_linear);
        H_linear_data(:,:,2,:) = imag(H_linear);
    
        H_practical_data(:,:,1,:) = real(H_practical);
        H_practical_data(:,:,2,:) = imag(H_practical);

        % true channel data
        H_current_data(:,:,1,:) = real(H_true_current);
        H_current_data(:,:,2,:) = imag(H_true_current);
    
            % symb x subc x 2 x samples x 1 (BS_ant) 
            %         to get size in python
            %         samples (noUE) x 2 x subc x symb
    end




    if flag_split == 1
        % split the real/image parts and save
        save([save_folder, '/', 'mapBaseData.mat'], 'H_current_data', ... % 14 (OFDM_current) x 612 x 2 x nUE
                                                'H_time_current', ... % 15360*n_slot_current x nUE
                                                'H_time_future', ...  % 15360*n_slot_future  x nUE
                                                'H_true_future', ...  % OFDM_future x 612 x nUE (complex)
                                                'H_time', ...         % 15360*n_slot x nUE (both current and future)
                                                'H_true', ...         % 14*(slot_current + slot_future) x 612 x nUE
                                                'H_linear_data', ...  
                                                'H_equalized_data', 'H_practical_data', '-v7.3');
    else
        % save complex matrices
                % split the real/image parts and save
        save([save_folder, '/', 'mapBaseData.mat'], ...
                                    'H_time', ...         % 15360*n_slot x nUE (both current and future)
                                    'H_true', ...         % 14*(slot_current + slot_future) x 612 x nUE
                                    'H_equalized', ...    % 14 x 612 x nUE
                                    'H_linear', ...
                                    'H_practical', ...
                                    '-v7.3');
    end
end

