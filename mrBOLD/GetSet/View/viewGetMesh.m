function val = viewGetMesh(vw,param,varargin)
% Get data from various view structures
%
% This function is wrapped by viewGet. It should not be called by anything
% else other than viewGet.
%
% This function retrieves information from the view that relates to a
% specific component of the application.
%
% We assume that input comes to us already fixed and does not need to be
% formatted again.

if notDefined('vw'), vw = getCurView; end
if notDefined('param'), error('No parameter defined'); end

mrGlobals;
val = [];


switch param
    
    case 'allmeshes'
        % Return the structs for all currently loaded meshes.
        %   allmeshes = viewGet(vw, 'all meshes');
        if checkfields(vw,'mesh'), val = vw.mesh; end
    case 'allmeshids'
        % Return the ID list for all meshes. IDs are numbers generated by
        % mrMesh that are associated with each new mesh session. They are
        % typically 4 digit numbers starting at 1001. (why??)
        %   idList = viewGet(vw,'All Window IDs');
        nMesh = viewGet(vw,'nmesh');
        if nMesh > 0
            val = zeros(size(val));
            for ii=1:nMesh, val(ii) = vw.mesh{ii}.id; end
            val = val(val > -1);
        end
    case 'mesh'
        % Return the mesh structure for the selected or the requested mesh.
        % If the mesh number is specificied, it indexes the cell array of
        % meshes currently attached to the view structure. The mesh number
        % bears no relation to the mesh ID number, which is generated by
        % the mesh server.
        %   msh = viewGet(vw, 'mesh');
        %   meshnum = 1; msh = viewGet(vw, 'mesh', meshnum);
        if ~isempty(varargin), whichMesh = varargin{1};
        else whichMesh = viewGet(vw,'currentmeshnumber'); end
        if ~isempty(whichMesh), val = vw.mesh{whichMesh}; end
    case 'currentmesh'
        % Return the mesh structure for the selected mesh. This is
        % redundant with the case 'mesh'.
        %   msh = viewGet(vw, 'Current Mesh');
        whichMesh = viewGet(vw,'Current Mesh Number');
        if ~isempty(whichMesh) && (whichMesh > 0), val = vw.mesh{whichMesh}; end
    case 'meshn'
        % Return the number of the currently selected mesh (index into the
        % cell array of meshes)
        %   msh = viewGet(vw, 'current mesh number');
        if checkfields(vw,'meshNum3d'), val = vw.meshNum3d; end
    case 'meshdata'
        % I think this is supposed to return the data displayed on the
        % current mesh, but I have just tried it and it doesn't seem to
        % work. So what does it do?
        %   meshData = viewGet(vw, 'current mesh data');
        if checkfields(vw,'mesh','data')
            selectedMesh = viewGet(vw,'current mesh number');
            val = vw.mesh{selectedMesh}.data;
        end
    case 'nmesh'
        % Return the number of meshes currently attached to the view
        % struct.
        %   nmesh = viewGet(vw, 'Number of Meshes');
        if checkfields(vw,'mesh'), val = length(vw.mesh); else val = 0; end
    case 'meshnames'
        % Return the name of all meshes currently attached to the view
        % struct.
        %   meshNames = viewGet(vw, 'mesh names');
        if checkfields(vw,'mesh')
            nMesh = viewGet(vw,'nmesh');
            val = cell(1,nMesh);
            for ii=1:nMesh
                if checkfields(vw.mesh{ii},'name')
                    val{ii} = vw.mesh{ii}.name;
                else val{ii} = [];
                end
            end
        end
    case 'meshdir'
        % Return the directory in which the currently selected mesh
        % resides. Default to anat dir if not found.
        %   meshDir = viewGet(vw, 'mesh directory');
        val = fileparts(getVAnatomyPath);
        
        % meshes are kept separately for each hemisphere
        % try to guess the hemisphere based on cursor position
        % but check whether this location actually exists!
        pos = viewGet(vw, 'Cursor Position');
        
        if ~isempty(pos),			% infer from sagittal position (high=right, low=left)
            vs = viewGet(vw,'Size');
            if (pos(3) < vs(3)/2),	hemi = 'Left';
            else					hemi = 'Right';
            end
            tmp = fullfile(val, hemi, '3DMeshes');
            if exist(tmp,'dir'),
                val = tmp;
            end
        end
        
        
    otherwise
        error('Unknown viewGet parameter');
        
end

return
