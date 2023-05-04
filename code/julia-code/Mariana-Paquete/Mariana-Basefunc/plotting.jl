function condense_autos_atorados_one_day(autos_atorados)
    max_number = maximum([pair[1] for pair in autos_atorados])
    Dict_autos_atorados = Dict()
    
    for i in 1:max_number
        all_pairs = [pair[2] for pair in autos_atorados if pair[1]==i]
        count = length(all_pairs)
        if count > 0.
            avg = mean(all_pairs)
        else
            avg = 0
        end
        Dict_autos_atorados[i] = [avg, count]
    end
    
    return Dict_autos_atorados
end

function merge_condensed_dicts(a,b)
    final_dict = Dict()
    for element in union(Set(keys(a)),Set(keys(b)))
        a_vals = get(a, element, [0,0])
        b_vals = get(b, element, [0,0])
        sum_for_avg = a_vals[1]*a_vals[2] + b_vals[1]*b_vals[2]
        count = a_vals[2] + b_vals[2]
        final_dict[element] = [sum_for_avg/count, count]
    end
    return final_dict
end
    
function autos_atorados_info(days_per_repetition, reads)
    final_dict = Dict()

    for j in 1:days_per_repetition
        final_dict = merge_condensed_dicts(final_dict,condense_autos_atorados_one_day(reads[string("day",j)][6]))
    end
    return final_dict
end

# Nan mean and nan mode
nanmean(x) = mean(filter(!isnan,x))
nanmean(x,y) = mapslices(nanmean,x,dims=y)
    
nanmode(x) = length(filter(!isnan,x))>0 ? StatsBase.mode(filter(!isnan,x)) : NaN
nanmode(x,y) = mapslices(nanmode,x,dims=y)

function get_information_by_car(days_per_repetition, number_of_cars, reads)
    # distance info    
    distances = [reads[string("day",j)][1][k]  for j in 1:days_per_repetition, k in 1:number_of_cars];
    car_distance_average = nanmean(distances, 1)[:];
    car_distance_mode = nanmode(round.(distances, digits=2), 1)[:];

    # Time info
    times = [reads[string("day",j)][2][k]  for j in 1:days_per_repetition, k in 1:number_of_cars];
    car_time_average = nanmean(times, 1)[:];
    car_time_mode = nanmode(round.(times, digits=2), 1)[:];
    
    # Speed info
    speeds = distances ./ times;
    car_speed_average = nanmean(speeds, 1)[:];
    car_speed_mode = nanmode(round.(speeds, digits=2), 1)[:];
    
    return car_speed_average, car_speed_mode, car_time_average, car_time_mode, car_distance_average, car_distance_mode
end
    
function get_information_by_day(days_per_repetition, number_of_cars, reads)
    # Distance info
    distances = [reads[string("day",j)][1][k]  for j in 1:days_per_repetition, k in 1:number_of_cars];
    day_distance_average = nanmean(distances, 2);
    day_distance_mode = nanmode(round.(distances, digits=2), 2);

    # Time info
    times = [reads[string("day",j)][2][k]  for j in 1:days_per_repetition, k in 1:number_of_cars];
    day_time_average = nanmean(times, 2);
    day_time_mode = nanmode(round.(times, digits=2), 2);
        
    # Speed info
    speeds = distances ./ times;
    day_speed_average = nanmean(speeds, 2);
    day_speed_mode = nanmode(round.(speeds, digits=2), 2);

    # NaN proportion
    day_nan_proportion = count(isnan, mean(times,dims=2))/days_per_repetition;

    # Get daily indexes and daily means
    daily_indexes = [reads[string("day",i)][3] for i in 1:days_per_repetition];
    daily_mean_indexes = [length(daily_indexes[i])>0 ? mean(daily_indexes[i]) : NaN for i in 1:days_per_repetition];
    daily_count_indexes = [length(daily_indexes[i]) for i in 1:days_per_repetition]

    return (day_speed_average, day_speed_mode, day_time_average,
            day_time_mode, day_distance_average, day_distance_mode,
            daily_mean_indexes, daily_count_indexes, day_nan_proportion)
end
    
function summary_df(days_per_repetition, number_of_cars, reads)
    # Distance info
    distances = [reads[string("day",j)][1][k]  for j in 1:days_per_repetition, k in 1:number_of_cars];
    
    # Time info
    times = [reads[string("day",j)][2][k]  for j in 1:days_per_repetition, k in 1:number_of_cars];
    
    # Speed info
    speeds = distances ./ times;
    
    # Get daily indexes and daily means
    daily_indexes = [reads[string("day",i)][3] for i in 1:days_per_repetition];
    daily_count_indexes = [length(daily_indexes[i]) for i in 1:days_per_repetition];

    df = DataFrame(a = 1:days_per_repetition,
               distances = [distances[i,:] for i in 1:days_per_repetition],
               times = [times[i,:] for i in 1:days_per_repetition],
               speeds = [speeds[i,:] for i in 1:days_per_repetition],
               ind = daily_indexes,
               ind_count = daily_count_indexes);
    return df
end

function red_daily_information(days_per_repetition, number_of_cars, reads)

    # Get daily red speeds and means
    daily_red_vels = [reads[string("day",i)][4] for i in 1:days_per_repetition];
    daily_mean_red_vels = [mean(filter(!isnan, daily_red_vels[i])) for i in 1:days_per_repetition];
    daily_count_red_vels = [length(daily_red_vels[i]) for i in 1:days_per_repetition];

    daily_red_final_saturation = [reads[string("day",i)][5] for i in 1:days_per_repetition];

    return daily_mean_red_vels, daily_count_red_vels, daily_red_final_saturation
end