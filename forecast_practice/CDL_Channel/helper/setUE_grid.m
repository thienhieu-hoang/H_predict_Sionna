function UE_grid = setUE_grid(UE_grid, plot_flag, idx_grid, idx_point, idx_UE, bsSite, pm, onlyLOS_flag, ueArray, bsArray, fc, fd, ofdmInfo, ueArrayOrientation, bsArrayOrientation, channel_SampleDensity)
    uePosition = UE_grid{idx_grid}.pointInside(idx_point,:); % lat, lon
    
    ueSite = rxsite("Name",['UE', num2str(idx_UE)], ...
        "Latitude",uePosition(1),"Longitude",uePosition(2),...
        "AntennaHeight",1 ... % in m
        );
    UE_grid{idx_grid}.rays{idx_point} = raytrace(bsSite,ueSite,pm,"Type","pathloss");
    if plot_flag
        show(ueSite);
        plot(UE_grid{idx_grid}.rays{idx_point}{1})
    end
    
    % temp variables
    pathToAs = [UE_grid{idx_grid}.rays{idx_point}{1}.PropagationDelay]-min([UE_grid{idx_grid}.rays{idx_point}{1}.PropagationDelay]);  % Time of arrival of each ray (normalized to 0 sec)
    avgPathGains  = -[UE_grid{idx_grid}.rays{idx_point}{1}.PathLoss];                                    % Average path gains of each ray
    pathAoDs = [UE_grid{idx_grid}.rays{idx_point}{1}.AngleOfDeparture];                                  % AoD of each ray
    pathAoAs = [UE_grid{idx_grid}.rays{idx_point}{1}.AngleOfArrival];                                    % AoA of each ray
    isLOS = any([UE_grid{idx_grid}.rays{idx_point}{1}.LineOfSight]);                                     % Line of sight flag
    if (~isLOS) && onlyLOS_flag
        error("Should be LOS");  % stop checking
    end
    
    UE_grid{idx_grid}.channel{idx_point} = nrCDLChannel;
    UE_grid{idx_grid}.channel{idx_point}.MaximumDopplerShift = fd;
    UE_grid{idx_grid}.channel{idx_point}.SampleDensity = channel_SampleDensity;
    
    UE_grid{idx_grid}.channel{idx_point}.RandomStream = 'Global stream';
    UE_grid{idx_grid}.channel{idx_point}.DelayProfile = 'Custom';
    UE_grid{idx_grid}.channel{idx_point}.PathDelays = pathToAs;
    UE_grid{idx_grid}.channel{idx_point}.AveragePathGains = avgPathGains;
    UE_grid{idx_grid}.channel{idx_point}.AnglesAoD = pathAoDs(1,:);       % azimuth of departure
    UE_grid{idx_grid}.channel{idx_point}.AnglesZoD = 90-pathAoDs(2,:);    % channel uses zenith angle, rays use elevation
    UE_grid{idx_grid}.channel{idx_point}.AnglesAoA = pathAoAs(1,:);       % azimuth of arrival
    UE_grid{idx_grid}.channel{idx_point}.AnglesZoA = 90-pathAoAs(2,:);    % channel uses zenith angle, rays use elevation
    UE_grid{idx_grid}.channel{idx_point}.HasLOSCluster = isLOS;
    UE_grid{idx_grid}.channel{idx_point}.CarrierFrequency = fc;
    UE_grid{idx_grid}.channel{idx_point}.NormalizeChannelOutputs = false; % do not normalize by the number of receive antennas, this would change the receive power
    UE_grid{idx_grid}.channel{idx_point}.NormalizePathGains = false;      % set to false to retain the path gains
        
    UE_grid{idx_grid}.channel{idx_point}.ReceiveAntennaArray = ueArray;
    UE_grid{idx_grid}.channel{idx_point}.ReceiveArrayOrientation = [ueArrayOrientation(1); (-1)*ueArrayOrientation(2); 0];  % the (-1) converts elevation to downtilt
    
    UE_grid{idx_grid}.channel{idx_point}.TransmitAntennaArray = bsArray;
    UE_grid{idx_grid}.channel{idx_point}.TransmitArrayOrientation = [bsArrayOrientation(1); (-1)*bsArrayOrientation(2); 0];   % the (-1) converts elevation to downtilt
    
    UE_grid{idx_grid}.channel{idx_point}.SampleRate = ofdmInfo.SampleRate;
    UE_grid{idx_grid}.channel{idx_point}.ChannelFiltering = true;
end

