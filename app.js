document.addEventListener('DOMContentLoaded', () => {
    let muscleData = [];
    const muscleListEl = document.getElementById('muscleList');
    const welcomeView = document.getElementById('welcomeView');
    const detailView = document.getElementById('detailView');
    const searchInput = document.getElementById('muscleSearch');
    const filterButtons = document.querySelectorAll('.filter-tabs button');

    // DOM Elements for details
    const elName = document.getElementById('muscleName');
    const elGroup = document.getElementById('muscleGroup');
    const elPattern = document.getElementById('musclePattern');
    const elLandmarks = document.getElementById('muscleLandmarks');
    const elPlacement = document.getElementById('musclePlacement');
    const elSetup = document.getElementById('muscleSetup');
    const elDiagramImg = document.getElementById('muscleImage');
    const elMarker = document.createElement('div');
    elMarker.className = 'marker';

    // Template map as a module-level constant
    const TEMPLATE_MAP = {
        'torso_anterior': 'torso_anterior_1767207634077.png',
        'torso_posterior': 'torso_posterior_1767207647158.png',
        'arm_anterior': 'arm_anterior_1767207660314.png',
        'arm_posterior': 'arm_posterior_1767207673288.png',
        'arm_lateral': 'arm_lateral_1767207691519.png',
        'arm_medial': 'arm_medial_1767207702776.png',
        'forearm_anterior': 'arm_anterior_1767207660314.png',
        'forearm_posterior': 'arm_posterior_1767207673288.png',
        'thigh_medial': 'leg_front_template.png',
        'thigh_lateral': 'leg_front_template.png',
        'lowerleg_medial': 'leg_front_template.png',
        'lowerleg_lateral': 'leg_front_template.png',
        'hand_palmar': 'arm_anterior_1767207660314.png',
        'leg_anterior': 'leg_front_template.png',
        'leg_posterior': 'leg_back_template.png',
        'foot_plantar': 'leg_back_template.png',
        'foot_dorsal': 'leg_front_template.png'
    };

    const DEFAULT_TEMPLATE = 'torso_anterior_1767207634077.png';

    // Calibration state
    const toggleEditBtn = document.getElementById('toggleEditMode');
    const copyConfigBtn = document.getElementById('copyConfig');
    const copyStatus = document.getElementById('copyStatus');
    const imageWrapper = document.querySelector('.image-wrapper');
    let isEditing = false;
    let modifiedMarkers = JSON.parse(localStorage.getItem('spasticity_custom_markers') || '{}');
    let currentMuscleId = null;

    // Load Data
    fetch('data/muscles.json')
        .then(response => {
            if (!response.ok) {
                throw new Error(`Failed to load muscle data: ${response.status} ${response.statusText}`);
            }
            return response.json();
        })
        .then(data => {
            muscleData = data;
            renderList(muscleData);
        })
        .catch(err => {
            console.error('Error loading muscle data:', err);
            muscleListEl.textContent = 'Failed to load muscle data. Please refresh.';
        });

    function renderList(list) {
        muscleListEl.innerHTML = '';
        const fragment = document.createDocumentFragment();
        list.forEach(muscle => {
            const di = document.createElement('button');
            di.className = 'muscle-item';
            di.type = 'button';

            const title = document.createElement('h4');
            title.textContent = muscle.name;

            const group = document.createElement('span');
            group.textContent = muscle.group;

            di.appendChild(title);
            di.appendChild(group);
            di.addEventListener('click', () => showDetail(muscle, di));
            fragment.appendChild(di);
        });
        muscleListEl.appendChild(fragment);
    }

    function showDetail(muscle, element) {
        // Track current muscle for calibration
        currentMuscleId = muscle.id;

        // Toggle Active Class
        document.querySelectorAll('.muscle-item').forEach(el => el.classList.remove('active'));
        element.classList.add('active');

        // Update Content
        elName.textContent = muscle.name;
        elGroup.textContent = muscle.group;
        elPattern.textContent = muscle.pattern;
        elLandmarks.textContent = muscle.landmarks;
        elPlacement.textContent = muscle.placement;
        elSetup.textContent = muscle.setup;

        // Update image alt text for accessibility
        elDiagramImg.alt = `Anatomical diagram: ${muscle.name} - ${muscle.marker ? muscle.marker.body : 'no diagram'}`;

        // Cleanup Dosage
        const oldDosage = document.querySelector('.dosage-badge');
        if (oldDosage) oldDosage.remove();
        if (muscle.dosage) {
            const db = document.createElement('div');
            db.className = 'dosage-badge';
            db.textContent = `Dosage: ${muscle.dosage}`;
            detailView.querySelector('.image-wrapper').appendChild(db);
        }

        // Marker Handling
        const container = document.getElementById('diagramContainer');
        const placeholder = document.querySelector('.image-placeholder');

        if (!container) return;

        if (muscle.marker) {
            const template = TEMPLATE_MAP[muscle.marker.body] || DEFAULT_TEMPLATE;
            elDiagramImg.src = `images/${template}`;
            elDiagramImg.style.display = 'block';
            placeholder.style.display = 'none';

            // Use saved calibration position if available, otherwise use default
            const saved = modifiedMarkers[muscle.id];
            const markerX = saved ? saved.x : muscle.marker.x;
            const markerY = saved ? saved.y : muscle.marker.y;

            elMarker.style.left = `${markerX}%`;
            elMarker.style.top = `${markerY}%`;
            if (!container.contains(elMarker)) {
                container.appendChild(elMarker);
            }
        } else {
            elDiagramImg.style.display = 'none';
            placeholder.style.display = 'flex';
            if (elMarker.parentNode) elMarker.remove();
        }

        // Switch Views
        welcomeView.style.display = 'none';
        detailView.style.display = 'block';
    }

    // Search Logic with debounce
    let searchTimeout = null;
    searchInput.addEventListener('input', (e) => {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(() => {
            const term = e.target.value.toLowerCase();
            const filtered = muscleData.filter(m =>
                m.name.toLowerCase().includes(term) ||
                m.pattern.toLowerCase().includes(term)
            );
            renderList(filtered);
        }, 150);
    });

    // Filter Logic
    filterButtons.forEach(btn => {
        btn.onclick = () => {
            filterButtons.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');

            const filter = btn.dataset.filter;
            if (filter === 'all') {
                renderList(muscleData);
            } else {
                const term = filter === 'UE' ? 'Upper' : 'Lower';
                const filtered = muscleData.filter(m => m.group.includes(term));
                renderList(filtered);
            }
        };
    });

    // ---------------------------------------------------------
    // CALIBRATION LOGIC
    // ---------------------------------------------------------
    toggleEditBtn.addEventListener('click', () => {
        isEditing = !isEditing;
        document.body.classList.toggle('editing-mode', isEditing);
        toggleEditBtn.textContent = isEditing ? 'Disable Editing' : 'Enable Editing';
        toggleEditBtn.classList.toggle('calibration-active', isEditing);
    });

    imageWrapper.addEventListener('click', (e) => {
        if (!isEditing || !currentMuscleId) return;

        const rect = imageWrapper.getBoundingClientRect();
        const xPercent = ((e.clientX - rect.left) / rect.width) * 100;
        const yPercent = ((e.clientY - rect.top) / rect.height) * 100;

        // Update visuals immediately
        elMarker.style.left = `${xPercent}%`;
        elMarker.style.top = `${yPercent}%`;

        // Save to local state
        modifiedMarkers[currentMuscleId] = { x: Math.round(xPercent), y: Math.round(yPercent) };
        localStorage.setItem('spasticity_custom_markers', JSON.stringify(modifiedMarkers));

        // Visual feedback
        elMarker.style.transform = 'translate(-50%, -50%) scale(1.5)';
        setTimeout(() => elMarker.style.transform = 'translate(-50%, -50%) scale(1)', 200);
    });

    copyConfigBtn.addEventListener('click', () => {
        const exportData = muscleData.map(m => {
            if (modifiedMarkers[m.id]) {
                const updated = modifiedMarkers[m.id];
                const mCopy = structuredClone(m);
                if (!mCopy.marker) mCopy.marker = { body: 'unknown', x: 0, y: 0 };
                mCopy.marker.x = updated.x;
                mCopy.marker.y = updated.y;
                return mCopy;
            }
            return m;
        });

        navigator.clipboard.writeText(JSON.stringify(exportData, null, 2))
            .then(() => {
                copyStatus.style.display = 'block';
                setTimeout(() => copyStatus.style.display = 'none', 3000);
            })
            .catch(err => console.error('Failed to copy config:', err));
    });
});
