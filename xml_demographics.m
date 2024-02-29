%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% xml_demographics.m -- Extract age and gender from MUSE and Philips XML
% Copyright 2016-2024 Hans F. Stabenau and Jonathan W. Waks
% 
% Source code/executables: https://github.com/BIVectors/BRAVEHEART
% Contact: braveheart.ecg@gmail.com
% 
% BRAVEHEART is free software: you can redistribute it and/or modify it under the terms of the GNU 
% General Public License as published by the Free Software Foundation, either version 3 of the License, 
% or (at your option) any later version.
%
% BRAVEHEART is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
% without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
% See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License along with this program. 
% If not, see <https://www.gnu.org/licenses/>.
%
% This software is for research purposes only and is not intended to diagnose or treat any disease.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [age, gender] = xml_demographics(filename, ecg_string)

  
 switch ecg_string  

    case 'muse_xml'
        % Deal with parsing issues with xmlread
        % Create Document Builder
        builder = javax.xml.parsers.DocumentBuilderFactory.newInstance;

        % Disable dtd validation
        builder.setFeature('http://apache.org/xml/features/nonvalidating/load-external-dtd', false);

        % Read the xml file
        tree = xmlread(filename, builder);
        
        try         % If there are errors during xml parsing, assign default age=50 and default gender=male
            patient_demographics = tree.getElementsByTagName('PatientDemographics');
        
            % Extract gender and age
            try
                age =  str2num(patient_demographics.item(0).getElementsByTagName('PatientAge').item(0).getFirstChild.getNodeValue);
            catch ME
                age = 50;
            end

            try
                gender =  char(patient_demographics.item(0).getElementsByTagName('Gender').item(0).getFirstChild.getNodeValue);
            catch ME
                gender = 'MALE';
            end
            
        catch ME
            age = 50;
            gender = 'MALE';
            
        end
   
     case 'philips_xml'
        % Deal with parsing issues with xmlread
        % Create Document Builder
        builder = javax.xml.parsers.DocumentBuilderFactory.newInstance;

        % Disable dtd validation
        builder.setFeature('http://apache.org/xml/features/nonvalidating/load-external-dtd', false);

        % Read the xml file
        tree = xmlread(filename, builder);
        
        try
            patient_demographics = tree.getElementsByTagName('age');
            age =  str2num(patient_demographics.item(0).getElementsByTagName('years').item(0).getFirstChild.getNodeValue);
        catch ME
            age = 50;
        end
         
        try 
            patient_demographics = tree.getElementsByTagName('sex');
            gender = char(patient_demographics.item(0).getFirstChild.getNodeValue);
        catch ME
            gender = 'MALE';
        end

     case 'cardiosoft_xml'
        % Deal with parsing issues with xmlread
        % Create Document Builder
        builder = javax.xml.parsers.DocumentBuilderFactory.newInstance;

        % Disable dtd validation
        builder.setFeature('http://apache.org/xml/features/nonvalidating/load-external-dtd', false);

        % Read the xml file
        tree = xmlread(filename, builder);
        
        try
            patient_demographics = tree.getElementsByTagName('Age');
            age =  str2num(patient_demographics.item(0).getFirstChild.getNodeValue);
        catch ME
            age = 50;
        end
         
        try 
            patient_demographics = tree.getElementsByTagName('Gender');
            gender = char(patient_demographics.item(0).getFirstChild.getNodeValue);
        catch ME
            gender = 'MALE';
        end
         

     otherwise
        age = 50;
        gender = 'MALE';
        
 end        % end switch
 
     % Double check that got an appropriate number for age and a string of male or female for gender     
     if ~isnumeric(age)
         age = 50;
     end
     
     if age < 0
         age = 50;
     end
     
     if strcmp(gender,'MALE') == 0 & strcmp(gender,'FEMALE') == 0
         gender = 'MALE';
     end



 end