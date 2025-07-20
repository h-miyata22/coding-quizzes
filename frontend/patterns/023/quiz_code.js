// 使用例
import React, { useState } from 'react';

// 基本的な使用方法
function BasicModal() {
  return (
    <Modal>
      <Modal.Trigger>
        <button>Open Modal</button>
      </Modal.Trigger>
      <Modal.Content>
        <Modal.Header>
          <h2>Welcome</h2>
          <Modal.Close>×</Modal.Close>
        </Modal.Header>
        <Modal.Body>
          <p>This is a basic modal dialog.</p>
        </Modal.Body>
        <Modal.Footer>
          <Modal.Close>
            <button>Close</button>
          </Modal.Close>
        </Modal.Footer>
      </Modal.Content>
    </Modal>
  );
}

// 確認ダイアログ
function ConfirmDialog() {
  const handleDelete = () => {
    console.log('Item deleted');
    // Delete logic here
  };
  
  return (
    <Modal>
      <Modal.Trigger>
        <button>Delete Item</button>
      </Modal.Trigger>
      <Modal.Content>
        <Modal.Header>
          <h2>Confirm Delete</h2>
        </Modal.Header>
        <Modal.Body>
          <p>Are you sure you want to delete this item?</p>
          <p>This action cannot be undone.</p>
        </Modal.Body>
        <Modal.Footer>
          <Modal.Close>
            <button>Cancel</button>
          </Modal.Close>
          <Modal.Close>
            <button onClick={handleDelete} style={{ backgroundColor: '#dc3545', color: 'white' }}>
              Delete
            </button>
          </Modal.Close>
        </Modal.Footer>
      </Modal.Content>
    </Modal>
  );
}

// フォーム付きモーダル
function FormModal() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    message: ''
  });
  
  const handleSubmit = (e) => {
    e.preventDefault();
    console.log('Form submitted:', formData);
  };
  
  return (
    <Modal>
      <Modal.Trigger>
        <button>Contact Us</button>
      </Modal.Trigger>
      <Modal.Content>
        <Modal.Header>
          <h2>Contact Form</h2>
          <Modal.Close>×</Modal.Close>
        </Modal.Header>
        <form onSubmit={handleSubmit}>
          <Modal.Body>
            <div style={{ marginBottom: '16px' }}>
              <label htmlFor="name">Name</label>
              <input
                id="name"
                type="text"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                style={{ width: '100%', padding: '8px' }}
              />
            </div>
            <div style={{ marginBottom: '16px' }}>
              <label htmlFor="email">Email</label>
              <input
                id="email"
                type="email"
                value={formData.email}
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                style={{ width: '100%', padding: '8px' }}
              />
            </div>
            <div style={{ marginBottom: '16px' }}>
              <label htmlFor="message">Message</label>
              <textarea
                id="message"
                value={formData.message}
                onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                style={{ width: '100%', padding: '8px', minHeight: '100px' }}
              />
            </div>
          </Modal.Body>
          <Modal.Footer>
            <Modal.Close>
              <button type="button">Cancel</button>
            </Modal.Close>
            <button type="submit">Submit</button>
          </Modal.Footer>
        </form>
      </Modal.Content>
    </Modal>
  );
}

// 制御されたモーダル
function ControlledModal() {
  const [isOpen, setIsOpen] = useState(false);
  const [step, setStep] = useState(1);
  
  const handleNext = () => {
    if (step < 3) {
      setStep(step + 1);
    } else {
      setIsOpen(false);
      setStep(1);
    }
  };
  
  return (
    <div>
      <Modal open={isOpen} onOpenChange={setIsOpen}>
        <Modal.Trigger>
          <button>Start Tutorial</button>
        </Modal.Trigger>
        <Modal.Content>
          <Modal.Header>
            <h2>Tutorial - Step {step} of 3</h2>
            <Modal.Close>×</Modal.Close>
          </Modal.Header>
          <Modal.Body>
            {step === 1 && <p>Welcome to our tutorial! Let's get started.</p>}
            {step === 2 && <p>Here's how to use the main features...</p>}
            {step === 3 && <p>You're all set! Ready to begin?</p>}
          </Modal.Body>
          <Modal.Footer>
            {step > 1 && (
              <button onClick={() => setStep(step - 1)}>Previous</button>
            )}
            <button onClick={handleNext}>
              {step < 3 ? 'Next' : 'Finish'}
            </button>
          </Modal.Footer>
        </Modal.Content>
      </Modal>
      
      <p>Tutorial completed: {step > 3 ? 'Yes' : 'No'}</p>
    </div>
  );
}

// 画像ギャラリーモーダル
function ImageModal() {
  const images = [
    { id: 1, src: '/image1.jpg', alt: 'Sunset' },
    { id: 2, src: '/image2.jpg', alt: 'Mountain' },
    { id: 3, src: '/image3.jpg', alt: 'Ocean' }
  ];
  
  return (
    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '16px' }}>
      {images.map(image => (
        <Modal key={image.id}>
          <Modal.Trigger>
            <img 
              src={image.src} 
              alt={image.alt}
              style={{ width: '100%', cursor: 'pointer' }}
            />
          </Modal.Trigger>
          <Modal.Content style={{ maxWidth: '800px' }}>
            <Modal.Header>
              <h2>{image.alt}</h2>
              <Modal.Close>×</Modal.Close>
            </Modal.Header>
            <Modal.Body>
              <img 
                src={image.src} 
                alt={image.alt}
                style={{ width: '100%' }}
              />
            </Modal.Body>
          </Modal.Content>
        </Modal>
      ))}
    </div>
  );
}

// カスタムスタイルモーダル
function StyledModal() {
  return (
    <Modal>
      <Modal.Trigger>
        <button className="fancy-button">Open Styled Modal</button>
      </Modal.Trigger>
      <Modal.Content className="custom-modal">
        <Modal.Header className="modal-gradient-header">
          <h2>Premium Feature</h2>
          <Modal.Close className="close-button">×</Modal.Close>
        </Modal.Header>
        <Modal.Body className="modal-body-styled">
          <div style={{ textAlign: 'center' }}>
            <span style={{ fontSize: '48px' }}>⭐</span>
            <h3>Upgrade to Premium</h3>
            <p>Unlock all features and get priority support</p>
          </div>
        </Modal.Body>
        <Modal.Footer className="modal-footer-centered">
          <Modal.Close>
            <button>Maybe Later</button>
          </Modal.Close>
          <button className="premium-button">
            Upgrade Now
          </button>
        </Modal.Footer>
      </Modal.Content>
    </Modal>
  );
}