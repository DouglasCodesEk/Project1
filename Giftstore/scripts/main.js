function addTouchSupport() {
    document.addEventListener('touchstart', function() {}, false);
}

document.addEventListener('DOMContentLoaded', () => {
    addTouchSupport();
    initSearch();
    // Remove the code that was setting the last occasion, as it's no longer needed
});

function initSearch() {
    const searchContainer = document.getElementById('search-container');
    let occasionButtons = '';
    for (let occasion in occasionQuestions) {
        occasionButtons += `<button onclick="startQuestionnaire('${occasion}')">${occasion.charAt(0).toUpperCase() + occasion.slice(1)}</button>`;
    }
    searchContainer.innerHTML = `
        <h2>Select a Gift Moment</h2>
        <div class="occasion-buttons">
            ${occasionButtons}
        </div>
    `;
    changeBackground('default'); // Reset to default background
}

const occasionQuestions = {
    "father's day": [
        {
            question: "What stage of fatherhood is he in?",
            options: ["Newly Dad", "Experienced Dad", "Granddad"]
        },
        {
            question: "What are his favorite hobbies?",
            options: ["Sports (Golf, Tennis, Football)", "DIY Projects", "Cooking", "Reading"]
        },
        {
            question: "What type of music does he enjoy?",
            options: ["60s Flower Power", "Classic Rock", "Jazz", "Electronic"]
        }
    ],
    "mother's day": [
        {
            question: "What's her preferred way to relax?",
            options: ["Spa Days", "Reading", "Gardening", "Cooking"]
        },
        {
            question: "What's her favorite type of jewelry?",
            options: ["Necklaces", "Earrings", "Bracelets", "Rings"]
        },
        {
            question: "What are her hobbies?",
            options: ["Arts & Crafts", "Yoga", "Traveling", "Photography"]
        }
    ],
    "christmas": [
        {
            question: "Who are you shopping for?",
            options: ["Family", "Friends", "Co-workers"]
        },
        {
            question: "What's their favorite holiday activity?",
            options: ["Decorating", "Baking", "Watching Movies", "Winter Sports"]
        },
        {
            question: "What's their age group?",
            options: ["Kids", "Teens", "Adults", "Seniors"]
        }
    ],
    "birthday": [
        {
            question: "What's their personality type?",
            options: ["Adventurous", "Creative", "Tech-Savvy", "Bookworm"]
        },
        {
            question: "What's the milestone?",
            options: ["Sweet 16", "21st Birthday", "30th Birthday", "50th Birthday"]
        },
        {
            question: "What's their favorite cuisine?",
            options: ["Italian", "Chinese", "Mexican", "Indian"]
        }
    ]
};

const occasionBackgrounds = {
    "father's day": 'fathersday-background.png',
    "mother's day": 'mothersday-background.png',
    "christmas": 'christmas-background.png',
    "birthday": 'birthday-background.png'
    // Add more occasions and their corresponding background images
};

function startQuestionnaire(occasion) {
    if (occasionQuestions[occasion]) {
        loadQuestions(occasion);
        changeBackground(occasion);
        localStorage.setItem('lastOccasion', occasion);
    } else {
        alert("Sorry, we don't have questions for that occasion yet.");
    }
}

function changeBackground(occasion) {
    const backgroundContainer = document.getElementById('background-container');
    if (occasion === 'default' || !occasionBackgrounds[occasion]) {
        backgroundContainer.style.backgroundImage = 'url("images/default-background.png")';
    } else {
        backgroundContainer.style.backgroundImage = `url('images/${occasionBackgrounds[occasion]}')`;
    }
}

function loadQuestions(occasion) {
    const searchContainer = document.getElementById('search-container');
    const questions = occasionQuestions[occasion];
    
    let questionsHTML = `<h2>${occasion.charAt(0).toUpperCase() + occasion.slice(1)} Gift Finder</h2>`;
    questionsHTML += `<div class="progress-bar"><div class="progress" style="width: 0%"></div></div>`;
    
    questions.forEach((q, index) => {
        questionsHTML += `
            <div class="question" id="question${index}" ${index > 0 ? 'style="display:none;"' : ''}>
                <p>${q.question}</p>
                ${q.options.map(option => `
                    <input type="checkbox" id="${option}" name="trait${index}" value="${option}">
                    <label for="${option}">${option}</label><br>
                `).join('')}
                ${index < questions.length - 1 ? `<button onclick="nextQuestion(${index})">Next</button>` : ''}
                ${index > 0 ? `<button onclick="previousQuestion(${index})">Previous</button>` : ''}
            </div>
        `;
    });
    
    questionsHTML += `
        <button onclick="searchGifts('${occasion}')" id="searchButton" style="display:none;">Find Gifts</button>
        <button onclick="clearForm()">Clear</button>
        <button onclick="initSearch()">Back</button>
    `;
    
    searchContainer.innerHTML = questionsHTML;
}

function nextQuestion(currentIndex) {
    document.getElementById(`question${currentIndex}`).style.display = 'none';
    document.getElementById(`question${currentIndex + 1}`).style.display = 'block';
    updateProgressBar(currentIndex + 1);
}

function previousQuestion(currentIndex) {
    document.getElementById(`question${currentIndex}`).style.display = 'none';
    document.getElementById(`question${currentIndex - 1}`).style.display = 'block';
    updateProgressBar(currentIndex - 1);
}

function updateProgressBar(currentIndex) {
    const progressBar = document.querySelector('.progress');
    const totalQuestions = occasionQuestions[occasion].length;
    const targetProgress = ((currentIndex + 1) / totalQuestions) * 100;

    let currentProgress = parseFloat(progressBar.style.width) || 0;

    function animate() {
        if (currentProgress < targetProgress) {
            currentProgress += 2;
            progressBar.style.width = `${currentProgress}%`;
            requestAnimationFrame(animate);
        } else {
            progressBar.style.width = `${targetProgress}%`;
        }
    }

    requestAnimationFrame(animate);

    if (currentIndex === totalQuestions - 1) {
        document.getElementById('searchButton').style.display = 'block';
    } else {
        document.getElementById('searchButton').style.display = 'none';
    }
}

function clearForm() {
    const checkboxes = document.querySelectorAll('input[type="checkbox"]');
    checkboxes.forEach(checkbox => checkbox.checked = false);
}

function searchGifts(occasion) {
    const traits = [];
    occasionQuestions[occasion].forEach((q, index) => {
        const selectedOptions = Array.from(document.querySelectorAll(`input[name="trait${index}"]:checked`)).map(cb => cb.value);
        traits.push(...selectedOptions);
    });
    if (traits.length === 0) {
        alert("Please select at least one option before searching.");
        return;
    }
    const searchQuery = buildSearchQuery(traits);
    searchProducts(searchQuery);
}

//REMEMBER TO LOOK ThiS up
const AWS = require('aws-sdk');
const { AMAZON_ACCESS_KEY, AMAZON_SECRET_KEY } = process.env;

AWS.config.update({
    accessKeyId: AMAZON_ACCESS_KEY,
    secretAccessKey: AMAZON_SECRET_KEY,
    region: 'us-east-1' // Update as needed
});

// Function to search products
function searchProducts(keywords) {
    showLoading();
    // Simulate API call with setTimeout
    setTimeout(() => {
        console.log('Searching for products with keywords:', keywords);
        // TODO: Implement actual API call using AWS SDK
        hideLoading();
        displayResults(['Sample Gift 1', 'Sample Gift 2', 'Sample Gift 3']);
    }, 2000);
}

let currentPage = 1;
const itemsPerPage = 10;

function displayResults(gifts) {
    const searchContainer = document.getElementById('search-container');
    let resultsHTML = '<h3>Gift Suggestions:</h3><ul id="giftList">';
    gifts.slice(0, itemsPerPage).forEach(gift => {
        resultsHTML += `<li>${gift}</li>`;
    });
    resultsHTML += '</ul>';
    if (gifts.length > itemsPerPage) {
        resultsHTML += '<button onclick="loadMoreResults()">Load More</button>';
    }
    searchContainer.innerHTML += resultsHTML;
}

function loadMoreResults() {
    currentPage++;
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    const giftList = document.getElementById('giftList');
    gifts.slice(startIndex, endIndex).forEach(gift => {
        const li = document.createElement('li');
        li.textContent = gift;
        giftList.appendChild(li);
    });
    if (endIndex >= gifts.length) {
        document.querySelector('button[onclick="loadMoreResults()"]').style.display = 'none';
    }
}

function showLoading() {
    const searchContainer = document.getElementById('search-container');
    searchContainer.innerHTML += '<div class="spinner"></div>';
}

function hideLoading() {
    const spinner = document.querySelector('.spinner');
    if (spinner) spinner.remove();
}

const traitKeywordMap = {
    'Newly Dad': ['baby care', 'new dad gifts'],
    'Experienced Dad': ['tools', 'grilling accessories'],
    'Granddad': ['classic novels', 'gardening tools'],
    'Sports (Golf, Tennis, Football)': ['golf clubs', 'tennis rackets', 'football gear'],
    'DIY Projects': ['power tools', 'craft supplies'],
    'Cooking': ['cookbooks', 'kitchen gadgets'],
    'Reading': ['bestselling books', 'e-readers'],
    '60s Flower Power': ['vintage records', 'tie-dye items'],
    'Classic Rock': ['rock band merchandise', 'guitar accessories'],
    'Jazz': ['jazz records', 'saxophone accessories'],
    'Electronic': ['synthesizer', 'DJ equipment'],
    'Spa Days': ['spa gift cards', 'aromatherapy sets', 'massage tools'],
    'Gardening': ['gardening tools', 'plant seeds', 'outdoor decor'],
    'Arts & Crafts': ['craft supplies', 'art kits', 'painting materials'],
    'Yoga': ['yoga mats', 'yoga blocks', 'meditation cushions'],
    'Traveling': ['travel accessories', 'luggage', 'travel guides'],
    'Photography': ['camera accessories', 'photo editing software', 'photography books'],
    'Decorating': ['home decor', 'Christmas ornaments', 'festive lights'],
    'Baking': ['baking tools', 'cookie cutters', 'recipe books'],
    'Watching Movies': ['streaming subscriptions', 'popcorn makers', 'home theater accessories'],
    'Winter Sports': ['ski gear', 'snowboarding equipment', 'winter clothing'],
    'Adventurous': ['outdoor gear', 'adventure books', 'travel accessories'],
    'Creative': ['art supplies', 'craft kits', 'creative software'],
    'Tech-Savvy': ['gadgets', 'smart home devices', 'tech accessories'],
    'Bookworm': ['e-readers', 'book subscriptions', 'reading lights'],
    // Add more mappings for other options
};

function buildSearchQuery(traits) {
    let keywords = [];
    traits.forEach(trait => {
        if (traitKeywordMap[trait]) {
            keywords = keywords.concat(traitKeywordMap[trait]);
        }
    });
    return keywords.join(' ');
}

function debounce(func, delay) {
    let debounceTimer;
    return function() {
        const context = this;
        const args = arguments;
        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(() => func.apply(context, args), delay);
    }
}

const debouncedSearchProducts = debounce(searchProducts, 300);

// Use debouncedSearchProducts instead of searchProducts in searchGifts function
