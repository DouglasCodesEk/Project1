const express = require('express');
const Web3 = require('web3');
const TestimonialContract = require('./contracts/TestimonialContract.json');
const cors = require('cors');

const app = express();
const web3 = new Web3(process.env.BLOCKCHAIN_NODE_URL);

const contractAddress = process.env.CONTRACT_ADDRESS;
const contract = new web3.eth.Contract(TestimonialContract.abi, contractAddress);

app.use(express.json());
app.use(cors());

app.post('/api/testimonial', async (req, res) => {
    try {
        const { content } = req.body;
        const accounts = await web3.eth.getAccounts();
        await contract.methods.addTestimonial(content).send({ from: accounts[0] });
        res.status(201).json({ message: 'Testimonial added successfully' });
    } catch (error) {
        console.error('Error adding testimonial:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

app.get('/api/testimonials', async (req, res) => {
    try {
        const count = await contract.methods.getTestimonialCount().call();
        const testimonials = [];
        for (let i = 0; i < count; i++) {
            const testimonial = await contract.methods.getTestimonial(i).call();
            testimonials.push({
                author: testimonial[0],
                content: testimonial[1],
                timestamp: testimonial[2]
            });
        }
        res.json(testimonials);
    } catch (error) {
        console.error('Error fetching testimonials:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
