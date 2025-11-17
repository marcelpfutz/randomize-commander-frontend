import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { CommonModule } from '@angular/common';
import { CommanderService } from '../../_services/commander.service';

@Component({
  selector: 'app-commander-detail',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './commander-detail.component.html',
  styleUrl: './commander-detail.component.css'
})
export class CommanderDetailComponent implements OnInit {
  commanderInfo: any = null;
  isLoading = false;

  constructor(
    private commanderService: CommanderService,
    private router: Router
  ) {
    // Recebe os dados da navegação
    const navigation = this.router.getCurrentNavigation();
    if (navigation?.extras.state) {
      this.commanderInfo = navigation.extras.state['commanderData'];
    }
  }

  ngOnInit() {
    // Se não recebeu dados pela navegação, carrega um novo
    if (!this.commanderInfo) {
      this.loadCommander();
    }
  }

  loadCommander() {
    this.isLoading = true;
    this.commanderInfo = null;
    
    this.commanderService.getCommanders().subscribe({
      next: (data) => {
        console.log('Commander data:', data);
        this.commanderInfo = data;
        this.isLoading = false;
      },
      error: (error) => {
        console.error('Error loading commander:', error);
        this.isLoading = false;
      }
    });
  }

  onRandomize() {
    this.loadCommander();
  }

  onBack() {
    this.router.navigate(['/']);
  }
}