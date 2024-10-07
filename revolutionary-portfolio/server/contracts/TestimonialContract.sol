pragma solidity ^0.8.0;

contract TestimonialContract {
    struct Testimonial {
        address author;
        string content;
        uint256 timestamp;
    }

    Testimonial[] public testimonials;

    event TestimonialAdded(address author, string content, uint256 timestamp);

    function addTestimonial(string memory _content) public {
        testimonials.push(Testimonial(msg.sender, _content, block.timestamp));
        emit TestimonialAdded(msg.sender, _content, block.timestamp);
    }

    function getTestimonialCount() public view returns (uint256) {
        return testimonials.length;
    }

    function getTestimonial(uint256 index) public view returns (address, string memory, uint256) {
        require(index < testimonials.length, "Invalid index");
        Testimonial memory t = testimonials[index];
        return (t.author, t.content, t.timestamp);
    }
}
