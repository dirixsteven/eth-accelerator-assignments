window.onload = () => {

    getAllBallers();
    // event catchers:
    contract.on("NewBaller", onNewBallerCallback);
}

async function getAllBallers() {
    let numBallers = await contract.getAmountCryptoBallers();
    console.log(numBallers);
    document.getElementById('ballers').innerHTML="<thead class='thead-dark'><tr class='tr-dark'><th>ID</th><th>Name</th><th>Level</th><th>Offense</th><th>Defense</th><th>Win/loss</th><th>Owner</th><th>Change my name</th></tr></thead>";
    for (var i = 0; i < numBallers; i++) {
        let baller = await contract.ballers(i);
        let owner = await contract.ownerOf(i);
        addBallerToTable(i, baller, owner);
    }
}

async function addBallerToTable(id, baller, owner) {
    // TODO: add owner address of baller
    document.getElementById('ballers').innerHTML+=`<tr class='tr-dark'>
    <td>${id}</td>
    <td>${baller.name}</td>
    <td>${baller.level}</td>
    <td>${baller.offenseSkill}</td>
    <td>${baller.defenseSkill}</td>
    <td>${baller.winCount}/${baller.lossCount}</td>
    <td>${owner}</td>
    <td><input type="text" id="new-name${id}"></input>&nbsp;&nbsp;<button type="button" class="btn btn-outline-primary btn-sm" data-index="${id}" onclick="changeMyName(${id})">Change my name</button></td>
    </tr>`;
}

async function getFreeBaller() {
    contract.claimFreeBaller().catch((reject) => showError(reject));
}

async function playBall() {
    let fighter1 = document.getElementById("fighter1").value;
    let fighter2 = document.getElementById("fighter2").value;
    await contract.playBall(fighter1, fighter2);
    getAllBallers();
}

async function onNewBallerCallback() {
    getAllBallers();
}

async function changeMyName(id) {
    let newName = document.getElementById("new-name" + id).value;
    await contract.changeName(id, newName);
    getAllBallers();
}

function showError(reject) {
    document.getElementById('error').innerHTML="There was an error: " + reject;
    document.getElementById('error').style.visibility = "visible";
}

async function buyNewBaller() {
    let overrides = {
        // The amount to send with the transaction (i.e. msg.value)
        value: ethers.utils.parseEther('0.1'),
    };
    let tx = await contract.buyBaller(overrides);
}
/*async function buyNewBaller() {
    let overrides = {
        // The amount to send with the transaction (i.e. msg.value)
        value: ethers.utils.parseEther('0.1'),
    };
    let tx = await contract.buyBaller(overrides);
}



/*
async function getElectionName() {
    let result = await contract.name();
    $('#name').html(result.toString());
}

async function getCandidates() {
    let numCandidate = await contract.getNumCandidate();
    for (var i = 0; i < numCandidate; i++) {
        let candidate = await contract.candidates(i);
        addCandidateToUI(candidate, i);
    }
}

async function addCandidateToUI(candidate, id) {
    let vote = candidate.voteCount;
    let total = await contract.totalVotes();
    let percentage = (vote * 100 / total).toFixed(2);
    percentage = isNaN(percentage)? 0 : percentage;

    $('#candidates').append(getCandidateHtml(candidate.name, id, percentage));
}

function getCandidateHtml(name, id, vote) {
    var html = `
                <div id="${name}" class="container candidate">
                    <div class="row">
                        <p class="lead">${name}</p>
                        <button type="button" class="btn btn-outline-primary btn-sm" data-index="${id}">Vote</button>
                    </div>
                    <div class="progress"><div class="progress-bar bg-info" role="progressbar" style="width: ${vote + "%"}" aria-valuenow="${vote}" aria-valuemin="0" aria-valuemax="100">${vote + "%"}</div></div>
                </div>
            `;
    return html;
}

$(document).on('click','.btn', function(e) {
    e.preventDefault(e);
    var candidateID = $(this).attr("data-index");
    contract.vote(candidateID).then(tx => console.log(tx));
})

async function onVoteCallback() {
    $('#candidates').empty();
    getCandidates();
}
*/