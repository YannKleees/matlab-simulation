%% DES
%  Discrete event simulation
%
%  Optional inputs
%       ND  number of productions
%       MI  maintenance interval in minutes
%       MT  maintenance time in minutes
%       POB payout boundary in minutes
%       POF payout fast
%       POS payout slow
%       CH  costs per hour
%
%  Outputs
%       avgWaitingTime  The average waiting time of customers in the queue (so arrival to finish)
%       avgQueueLength  The average queue length 
%       profit          The profit
function [avgWaitingTime, avgQueueLength, profit] = DES(ND, MI, MT, POB, POF, POS, CH)
    % Initialize DES
    if ((nargin < 1) || isempty(ND))
        ND = 50000; % default number of productions
    end
    if ((nargin < 2) || isempty(MI))
        MI = 200 * 60; % maintenance interval in minutes
    end
    if ((nargin < 3) || isempty(MT))
        MT = 20 * 60; % maintenance time in minutes
    end
    if ((nargin < 4) || isempty(POB))
        POB = 24 * 60; % payout boundary in minutes
    end
    if ((nargin < 5) || isempty(POF))
        POF = 25; % payout fast
    end
    if ((nargin < 6) || isempty(POS))
        POS = 10; % payout slow
    end
    if ((nargin < 7) || isempty(CH))
        CH  = 1000; % costs per hour
    end

    % Initialise system state
    t = 0; % simulation time
    S = 3; % amount of servers

    % next arrival time
    nextArrival = arrival();

    % server state arrays
    state          = zeros(1, S);
    eventTime      = inf(1, S);   
    eventType      = zeros(1, S);
    busySinceMaint = zeros(1, S);
    busyToAdd      = zeros(1, S);
    currentArrTime = nan(1, S);
    idleSince      = zeros(1, S);

    % queue of waiting jobs
    queueArrTimes = [];
    queueLength   = 0;

    % performance statistics
    numCompleted  = 0;
    sumSysTime    = 0;
    totalRevenue  = 0;
    queueArea     = 0;
    lastEventTime = 0;
    flagNthReached = false;

    %% DES loop
    while true
        [tNext, idx] = min([nextArrival, eventTime]);
        if isinf(tNext)
            break;
        end
        % update time‑average queue length
        dt = tNext - t;
        if dt < 0
            dt = 0;
        end
        queueArea = queueArea + queueLength * dt;
        t = tNext;
        if idx == 1
            %% ARRIVAL EVENT
            jobArr = t;

            % find idle servers
            idleServers = find(state == 0);

            if ~isempty(idleServers) && queueLength == 0
                % if multiple machines idle, assign to the one that has been idle the longest
                [~, pos] = min(idleSince(idleServers));
                j = idleServers(pos);
                % start service at server j
                state(j)          = 1;
                currentArrTime(j) = jobArr;
                sTime       = service();    
                busyRemain  = MI - busySinceMaint(j);
                if sTime <= busyRemain
                    % normal completion before maintenance trigger
                    eventType(j) = 1;
                    eventTime(j) = t + sTime;
                    busyToAdd(j) = sTime;
                else
                    % maintenance will start before job finishes
                    eventType(j) = 2;
                    eventTime(j) = t + busyRemain;
                    busyToAdd(j) = busyRemain;
                end
            else
                % no idle servers, job joins the queue
                queueArrTimes(end+1) = jobArr;
                queueLength          = queueLength + 1;
            end
            % schedule next arrival
            nextArrival = t + arrival();

        else
            %% SERVER EVENT
            j = idx - 1;

            if eventType(j) == 1
                % Service completion
                busySinceMaint(j)   = busySinceMaint(j) + busyToAdd(j);
                busyToAdd(j)        = 0;
                jobArr              = currentArrTime(j);
                currentArrTime(j)   = NaN;

                numCompleted        = numCompleted + 1;
                sojourn             = t - jobArr;

                % update stats
                sumSysTime = sumSysTime + sojourn;
                if sojourn <= POB
                    totalRevenue = totalRevenue + POF;
                else
                    totalRevenue = totalRevenue + POS;
                end

                % record that ND‑th job has been completed
                if ~flagNthReached && numCompleted >= ND
                    flagNthReached = true;
                end

                % check whether maintenance is now due on this server
                if busySinceMaint(j) >= MI - 1e-9
                    % go into maintenance immediately
                    state(j)          = 2;
                    busySinceMaint(j) = 0;
                    eventType(j)      = 3; 
                    eventTime(j)      = t + MT;
                    idleSince(j)      = inf;
                else
                    % server becomes idle and may immediately take a queued job
                    state(j)     = 0;
                    eventType(j) = 0;
                    eventTime(j) = inf;
                    idleSince(j) = t;

                    if queueLength > 0
                        % take next job from the front of the queue
                        jobArr = queueArrTimes(1);
                        if queueLength == 1
                            queueArrTimes = [];
                        else
                            queueArrTimes = queueArrTimes(2:end);
                        end
                        queueLength = queueLength - 1;

                        state(j)          = 1;
                        currentArrTime(j) = jobArr;
                        idleSince(j)      = 0;
                        sTime      = service();
                        busyRemain = MI - busySinceMaint(j);
                        if sTime <= busyRemain
                            eventType(j) = 1;
                            eventTime(j) = t + sTime;
                            busyToAdd(j) = sTime;
                        else
                            eventType(j) = 2;
                            eventTime(j) = t + busyRemain;
                            busyToAdd(j) = busyRemain;
                        end
                    end
                end

            elseif eventType(j) == 2
                % Maintenance start
                busySinceMaint(j) = busySinceMaint(j) + busyToAdd(j);
                busyToAdd(j)      = 0;

                % job finished and pushed back to queue
                jobArr            = currentArrTime(j);
                currentArrTime(j) = NaN;
                queueArrTimes = [jobArr, queueArrTimes];
                queueLength   = queueLength + 1;

                % server goes into maintenance
                state(j)          = 2;
                busySinceMaint(j) = 0;
                eventType(j)      = 3;
                eventTime(j)      = t + MT;
                idleSince(j)      = inf;

            elseif eventType(j) == 3
                % Maintenance end
                state(j)     = 0;
                eventType(j) = 0;
                eventTime(j) = inf;
                idleSince(j) = t;

                % after maintenance server can immediately take a queued job
                if queueLength > 0
                    jobArr = queueArrTimes(1);
                    if queueLength == 1
                        queueArrTimes = [];
                    else
                        queueArrTimes = queueArrTimes(2:end);
                    end
                    queueLength = queueLength - 1;

                    state(j)          = 1;
                    currentArrTime(j) = jobArr;
                    idleSince(j)      = 0;
                    sTime      = service();
                    busyRemain = MI - busySinceMaint(j);
                    if sTime <= busyRemain
                        eventType(j) = 1;
                        eventTime(j) = t + sTime;
                        busyToAdd(j) = sTime;
                    else
                        eventType(j) = 2;
                        eventTime(j) = t + busyRemain;
                        busyToAdd(j) = busyRemain;
                    end
                end
            else
                error('Unkown event type');
            end
        end

        % stopping condition
        jobsInSystem = queueLength + sum(state == 1);

        if flagNthReached && (jobsInSystem == 0)
            break;
        end
    end

    % Performance
    T = t;  % total simulated time
    avgWaitingTime = sumSysTime / numCompleted; % from arrival to finish
    avgQueueLength = queueArea   / T; % time-average queue length
    totalCost = CH * (T / 60); % convert minutes to hours
    profit = totalRevenue - totalCost;
end
