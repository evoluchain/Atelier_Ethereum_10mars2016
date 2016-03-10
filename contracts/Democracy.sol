contract Democracy {

    // Les variables de storage: elles sont stockées, accessibles et modifiables par des transactions

    // Combien de temps dure chaque vote?
    uint public votingTimeInMinutes;
    // Qui peut ajouter des membres et changer le temps de vote?
    address public owner;
    // Qui a le droit de vote?
    mapping (address => bool) public members;
    // Quelles sont les propositions sur lesquelles on vote? truc[] définit un tableau de truc
    Proposal[] public proposals;

    // La structure d'une proposition: on définit un "type"
    struct Proposal {
        string description;
        mapping (address => bool) voted;
        bool[] votes;
        uint end;
        bool adopted;
    }

    // Les modifiers permettent de modifier le comportement d'autres fonctions. Par exemple, ajouter un controle d'accès

    // Si la proposition correspondant à  cet index n'est pas ouverte au vote, la fonction n'est pas exécutée
    modifier isOpen(uint index) {
        if(now > proposals[index].end) throw;
        _
    }

    // ... l'inverse
    modifier isClosed(uint index) {
        if(now < proposals[index].end) throw;
        _
    }

    // Si le compte (msg.sender) a déjà  voté pour cette proposition, la fonction n'est pas exécutée
    modifier didNotVoteYet(uint index) {
        if(proposals[index].voted[msg.sender]) throw;
        _
    }

    // Vous avez compris
    modifier ownerOnly() {
        if(msg.sender != owner) throw;
        _
    }

    // Non?
    modifier memberOnly() {
        if(!members[msg.sender]) throw;
        _
    }

    // Les fonctions en tant que telles, appelées par les comptes

    function nbProposals() constant returns(uint nbProposals) {
        nbProposals = proposals.length;
    }

    // Constructeur du contrat. Cette fonction est appelée une seule fois, automatiquement, quand le contrat est déployé sur la blockchain.
    function Democracy(uint votingTime) {
        owner = msg.sender;
        setVotingTime(votingTime);
    }

    // "Setter" du temps de vote, accessible seulement à  l'owner
    function setVotingTime(uint newVotingTime) ownerOnly() {
        votingTimeInMinutes = newVotingTime;
    }

    // Ajouter un membre à  la démocratie
    function addMember(address newMember) ownerOnly() {
        members[newMember] = true;
    }

    // ajouter une proposition
    function addProposal(string description) memberOnly() {
        // Intuitivement on devrait pouvoir faire proposals.push(Proposal(...)), mais solidity ne gère pas encore très bien les arrays de struct
        // On utilise donc une technique un peu moins directe
        uint proposalID = proposals.length++;
        Proposal p = proposals[proposalID];
        // Donner la description
        p.description = description;
        // Donner le moment de fin du vote
        p.end = now + votingTimeInMinutes * 1 minutes;
        // ... le reste des paramètres est mis aux valeurs par défaut
        // p.adopted = false, p.votes = [], etc...
    }

    // Voter pour une proposition
    function vote(uint index, bool vote) memberOnly() isOpen(index) didNotVoteYet(index) {
        // on push le vote à  la liste de votes
        proposals[index].votes.push(vote);
        // on ajoute le votant au mapping des votants
        proposals[index].voted[msg.sender] = true;
    }

    function executeProposal(uint index) isClosed(index) {
        uint aye;
        uint no;
        bool[] votes = proposals[index].votes;
        // On compte les pour et les contre
        for(uint counter = 0; counter < votes.length; counter++) {
            if(votes[counter]) {
                aye++;
            } else {
                no++;
            }
        }
        if(aye > no) {
           proposals[index].adopted = true;
        }
    }
}