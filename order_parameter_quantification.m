%% load parent folder %%

warning off

uiwait(msgbox('Load parent folder'));
parent_d = uigetdir('');

matlab_folder = cd;
cd(parent_d)
listing = dir('**/piv_field_raw*.mat');
cd(matlab_folder)

%% open one file at a time and perform analysis %%

n_files = length(listing);

for file_list = 1:n_files
    
    % file and directory name
    file = listing(file_list).name;
    directory = listing(file_list).folder;
    
    vraw = load(fullfile ([directory, '/', file]));
    vraw = vraw.vraw;
    
    nt = length(vraw);
    
    for frame = 1:nt % loop through all frames
        
        field = vraw(frame);
        field_matrix = [field.x', field.y', field.vx', field.vy'];
        field_matrix_no0 = field_matrix(any(field_matrix,2),:);
        
        order_parameter = zeros(size(field_matrix_no0,1),1)*NaN;
        for k = 1:size(field_matrix_no0, 1) % loop through each vector
            
            xy = [field_matrix_no0(k,1) field_matrix_no0(k,2)];
            vx = field_matrix_no0(k,3);
            vy = field_matrix_no0(k,4);
            
            % define box
            grid_size_PIV = 8;  % [px]
            idx1 = xy(1) + grid_size_PIV;
            idx2 = xy(1) - grid_size_PIV;
            idy1 = xy(2) + grid_size_PIV;
            idy2 = xy(2) - grid_size_PIV;
            
            grid1 = find(field_matrix_no0(:,1) == idx2 & field_matrix_no0(:,2) == idy1);
            grid2 = find(field_matrix_no0(:,1) == xy(1) & field_matrix_no0(:,2) == idy1);
            grid3 = find(field_matrix_no0(:,1) == idx1 & field_matrix_no0(:,2) == idy1);
            grid4 = find(field_matrix_no0(:,1) == idx2 & field_matrix_no0(:,2) == xy(2));
            grid5 = find(field_matrix_no0(:,1) == idx1 & field_matrix_no0(:,2) == xy(2));
            grid6 = find(field_matrix_no0(:,1) == idx2 & field_matrix_no0(:,2) == idy2);
            grid7 = find(field_matrix_no0(:,1) == xy(1) & field_matrix_no0(:,2) == idy2);
            grid8 = find(field_matrix_no0(:,1) == idx1 & field_matrix_no0(:,2) == idy2);
            
            grid = [grid1; grid2; grid3; grid4; grid5; grid6; grid7; grid8];
            
            costheta = zeros(size(grid,1),1)*NaN;
            for j = 1:size(grid, 1)
                
                vx1 = field_matrix_no0(grid(j),3);
                vy1 = field_matrix_no0(grid(j),4);
                
                costheta(j,1) = dot([vx vy],[vx1 vy1]) ./ ...
                    (norm([vx vy]) .* norm([vx1 vy1]));

            end
            order_parameter(k,1) = nanmean(abs(costheta(:)));
            clear costheta
        end
        
        data{file_list,1}(frame,1) = nanmean(order_parameter(:));
        clear order_parameter
        
    end
    
end

%% make data into a matrix %%

len = zeros(length(data), 1);
for ii = 1:length(data)
    len(ii,1) = length(data{ii,1});
end
max_len = max(len);

out = zeros(max_len, file_list)*NaN;
for ii = 1:file_list
    out(1:length(data{ii,1}),ii) = data{ii,1};
end

save(fullfile(parent_d, ...
    'cofilin_order_parameter.mat'), ...
    'out');
