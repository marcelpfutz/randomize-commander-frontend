import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { CommonModule } from '@angular/common';
import { CommanderService } from '../../_services/commander.service';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css']
})

export class HomeComponent{
    isLoading = false;

    constructor (
        private commanderService: CommanderService,
        private router: Router
    ){}

    onRandomize(){
        this.isLoading = true;

        this.commanderService.getCommanders().subscribe({
            next: (data) => {
                this.router.navigate(['/commander'], {
                    state: { commanderData: data}
                });
                this.isLoading = false;
            },
            error: (error) => {
                console.error('Erro ao carregar:', error);
                this.isLoading = false;
                alert('Erro ao carregar o comandante. Tente novamente');
            }
        });
    }
}