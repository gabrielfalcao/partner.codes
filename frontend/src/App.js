import React, { Component } from 'react';
import { Container, Box, Button, Columns, Column  } from 'bloomer';
import { Message , Notification, Delete, MessageHeader, MessageBody  } from 'bloomer';

import io from 'socket.io-client'

class App extends Component {
    constructor() {
        super()
        this.state = {
            message: 'Awaiting connections..'
        }


    }
    componentWillMount() {
        this.socket = io('http://localhost:5000', {
            transports: ['websocket']
        })
    }
    componentDidMount() {
        this.socket.on('connect', ()=> {
            this.setState({message: 'connected'})
        })
        this.socket.on('event', (data) => {
            this.setState({message: '  event', event: data})
        })
        this.socket.on('response', (data) => {
            this.setState({message: 'response', response: data})
        })
        this.socket.on('disconnect', () => {
            this.setState({message: 'disconnected'})
        })
    }
    onClickConnect = (e) => {
        e.preventDefault()
        this.setState({message: 'tryin...'})
        this.socket.connect()
        this.socket.emit('event', 'tobi', (data) => {
            this.setState({message: 'server received'})
        });
        this.socket.on('reconnect_attempt', () => {
            this.socket.io.opts.transports = ['polling', 'websocket'];
        });
    }
    render() {
        const {message, event, response} = this.state

        return (
            <Columns isCentered>
                <Column isSize='1/3'>
                    <Container isFluid style={{ marginTop: 10 }}>
                        <Message>
                            <MessageHeader>
                                <p>socket.io</p>
                            </MessageHeader>
                            <MessageBody>
                                <Button onClick={this.onClickConnect} isColor='success'>start</Button>
                            </MessageBody>
                        </Message>
                    </Container>
                </Column>
                <Column isSize='2/3'>
                    <Container isFluid style={{ marginTop: 10 }}>
                        {event ? <Notification isColor='warning' hasTextAlign='centered'>{JSON.stringify(event, null, 2)}</Notification> : null}
                        {response ? <Notification isColor='primary' hasTextAlign='centered'>{JSON.stringify(response, null, 2)}</Notification> : null}
                    </Container>
                </Column>
            </Columns>
        );
    }
}

export default App;
