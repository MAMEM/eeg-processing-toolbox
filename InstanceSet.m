classdef InstanceSet
    % A class for describing a set of instances and labels
    
    properties (Access = public)
        instances; % the instances
        labels; % the labels
    end
    
    methods
        function IS = InstanceSet(instances, labels)
            % obj = InstanceSet(instances, labels)
            % -instances : a m x n matrix where m = instances and n =
            % features
            % -labels: a m x 1 matrix containing the labels for each
            % instance
            IS.instances = instances;
            IS.labels = floor(labels);
        end
        
        function instances = getInstances(IS)
            % get the instances 
            instances = IS.instances;
        end
        function labels = getLabels(IS)
            % get the labels
            labels = IS.labels;
        end
        
        function numLabels = getNumLabels(IS)
        end
            
        function dataset = getDataset(IS)
            % same with getInstances but includes the labels as the last
            % row
            dataset = horzcat(IS.instances,IS.labels);
        end
        function writeCSV(IS, csvname)
            % write the dataset to a csv file
            % Example:
            %   obj.writeCSV('data.csv');
            csvwrite(csvname, IS.getDataset());
        end
        function writeArff(IS, fname)
            % write the dataset to a weka-readable file (arff)
            % Caution: filename without extension
            % Example:
            %   obj.writeArff('data')
            data = IS.getDataset();
%             data = horzcat(IS.instances,floor(IS.labels));
            sss=size(data,2)-1;
            filename1=strcat(fname,'.arff');
            out1 = fopen (filename1, 'w+');
            aa1=strcat('@relation',{' '},fname,'-weka.filters.unsupervised.attribute.NumericToNominal-Rlast');
            fprintf (out1, '%s\n', char(aa1));
            for jj=1:sss
                fprintf (out1, '@attribute %s numeric\n',num2str(jj));
            end
            n_classes=max(unique(data(:,end)));
            txt1=strcat('@attribute',{' '},num2str(sss+1),{' {'});
            
            for ii=1:n_classes
                txt1=strcat(txt1,num2str(ii),{','});
            end
            txt1=strcat(txt1,{'}'});
            
            fprintf (out1, '%s\n\n',char(txt1));
            fprintf (out1,'@data\n');
            
            fclose(out1);
            
            dlmwrite (filename1, data, '-append' );
        end
    end
    
end

